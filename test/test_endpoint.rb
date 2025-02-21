# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'test/unit'
require 'rack/test'
require_relative 'fake_server'
require_relative '../objects/base'
require_relative '../objects/endpoint'
require_relative '../objects/endpoints'
require_relative '../objects/dynamo'
require_relative '../objects/total_pings'

class EndpointTest < Test::Unit::TestCase
  def test_pings_valid_uri
    port = FakeServer.new.start(200)
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(
      "http://127.0.0.1:#{port}/"
    )
    ep = Base.new(dynamo).take(id)
    ping = ep.ping(TotalPings.new(0))
    assert(ping.end_with?('200'), ping)
  end

  def test_pings_broken_uri
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(
      'http://www.sixnines-broken-uri.io'
    )
    ep = Base.new(dynamo).take(id)
    ping = ep.ping(TotalPings.new(1))
    assert_false(ping.end_with?('200'), ping)
  end

  def test_pings_via_broken_proxy
    port = FakeServer.new.start(407)
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(
      'http://www.the-address-that-doesnt-exist-for-sure.com'
    )
    ep = Base.new(dynamo).take(id)
    ping = ep.ping(TotalPings.new(1), ["127.0.0.1:#{port}"])
    assert_true(ping.end_with?('200'), ping)
  end

  def test_flushes
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(
      'http://broken-url'
    )
    ep = Base.new(dynamo).take(id)
    ep.ping(TotalPings.new(2))
    assert_not_equal(nil, Base.new(dynamo).take(id).to_h[:log])
    ep.flush
    assert_equal(nil, Base.new(dynamo).take(id).to_h[:log])
  end

  def test_increments_ping_count
    port = FakeServer.new.start(200)
    initial = 3
    first_proxy = 'my-proxy.com:8080'
    second_proxy = 'my-other-proxy.com:3000'
    first_stub = stub_request(:any, first_proxy)
    second_stub = stub_request(:any, second_proxy)
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'pdacostaporto-endpoint').add(
      "http://127.0.0.1:#{port}/"
    )
    ep = Base.new(dynamo).take(id)
    pings = TotalPings.new(initial)
    ep.ping(pings, [first_proxy, second_proxy])
    assert_equal(initial + 1, pings.count)
    remove_request_stub(first_stub)
    remove_request_stub(second_stub)
  end
end
