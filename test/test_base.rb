# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'test/unit'
require 'rack/test'
require_relative 'fake_server'
require_relative '../objects/dynamo'
require_relative '../objects/base'

class BaseTest < Test::Unit::TestCase
  def test_lists_flips
    assert(!Base.new(Dynamo.new.aws).flips.nil?)
  end

  def test_tries_to_take_absent_endpoint
    assert_raise Base::EndpointNotFound do
      Base.new(Dynamo.new.aws).take('absent')
    end
  end

  def test_ping_increments_total_pings
    port = FakeServer.new.start(200)
    aws = Dynamo.new.aws
    Endpoints.new(
      aws, 'yegor256-endpoint-1'
    ).add("http://127.0.0.1:#{port}/first-A")
    Endpoints.new(
      aws,
      'pdacostaporto-endpoint-2'
    ).add("http://127.0.0.1:#{port}/second-B")
    first_proxy = 'my-proxy.com:8080'
    second_proxy = 'my-other-proxy:3000'
    first_stub = stub_request(:any, first_proxy)
    second_stub = stub_request(:any, second_proxy)
    increase = aws.scan(
      table_name: 'sn-endpoints'
    ).items.length
    initial = 42
    pings = TotalPings.new(initial)
    Base.new(aws).ping(pings, [first_proxy, second_proxy])
    assert_equal(initial + increase + 1, pings.count)
    remove_request_stub(first_stub)
    remove_request_stub(second_stub)
  end
end
