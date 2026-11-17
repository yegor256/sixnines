# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'glogin/cookie'
require_relative '../sixnines'
require_relative 'fake_server'
require_relative 'test__helper'

# Editing of endpoints, guarded by their success history
class EndpointEditTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_edit_refuses_endpoint_with_successful_pings
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    login = "tester-#{SecureRandom.hex(2)}"
    old = "http://www.#{SecureRandom.hex(2)}.com"
    Endpoints.new(dynamo, login).add(old)
    dynamo.update_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => login,
        'uri' => old
      },
      expression_attribute_values: {
        ':s' => 2
      },
      update_expression: 'set succeeds = :s'
    )
    login_as(login)
    error = assert_raises(RuntimeError) do
      post('/a/edit', { old: old, new: "http://www.#{SecureRandom.hex(2)}.com" })
    end
    assert_includes(error.message, 'successful pings', error.message)
    eps = Endpoints.new(dynamo, login).list
    assert_equal(
      [old],
      eps.map { |e| e.to_h[:uri].to_s },
      'The old endpoint must stay untouched'
    )
  end

  def test_edit_allows_endpoint_without_successful_pings
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    login = "tester-#{SecureRandom.hex(2)}"
    old = "http://www.#{SecureRandom.hex(2)}.com"
    new_uri = "http://www.#{SecureRandom.hex(2)}.com"
    Endpoints.new(dynamo, login).add(old)
    login_as(login)
    post('/a/edit', { old: old, new: new_uri })
    assert_predicate(
      last_response,
      :redirect?,
      'Edit must be allowed when there were no successful pings'
    )
    eps = Endpoints.new(dynamo, login).list
    assert_equal(1, eps.size)
    assert_equal(new_uri, eps[0].to_h[:uri].to_s)
  end

  def test_edit_allows_never_succeeded_endpoint_after_failed_ping_and_flush
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    login = "tester-#{SecureRandom.hex(2)}"
    port = FakeServer.new.start(500)
    old = "http://127.0.0.1:#{port}/"
    new_uri = "http://www.#{SecureRandom.hex(2)}.com"
    eps = Endpoints.new(dynamo, login)
    id = eps.add(old)
    Base.new(dynamo).take(id).ping(TotalPings.new(0)) # one failed ping
    Base.new(dynamo).take(id).flush # failures reset, success history intact
    login_as(login)
    post('/a/edit', { old: old, new: new_uri })
    assert_predicate(
      last_response,
      :redirect?,
      'Edit must be allowed: the endpoint has never pinged successfully'
    )
    assert_equal(
      [new_uri],
      eps.list.map { |e| e.to_h[:uri].to_s },
      'The old endpoint must be replaced by the new one'
    )
  end

  def test_edit_refuses_success_arriving_before_deletion
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    login = "tester-#{SecureRandom.hex(2)}"
    port = FakeServer.new.start(200)
    old = "http://127.0.0.1:#{port}/"
    new_uri = "http://www.#{SecureRandom.hex(2)}.com"
    eps = Endpoints.new(dynamo, login)
    id = eps.add(old)
    login_as(login)
    # The guard used to read the counters first (this read sees zero
    # successes) and delete the old endpoint afterwards; here a
    # background ping records the first success inside that window
    Base.new(dynamo).take(id).ping(TotalPings.new(0))
    error = assert_raises(RuntimeError) do
      post('/a/edit', { old: old, new: new_uri })
    end
    assert_includes(error.message, 'successful pings', error.message)
    assert_equal(
      [old],
      eps.list.map { |e| e.to_h[:uri].to_s },
      'The success recorded after the read must still refuse the edit'
    )
  end

  private

  def login_as(login)
    enc = GLogin::Cookie::Open.new({ 'login' => login, 'id' => '99999' }, '').to_s
    set_cookie("glogin=#{enc}")
  end
end
