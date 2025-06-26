# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative '../objects/base'
require_relative '../objects/dynamo'
require_relative 'fake_server'
require_relative 'test__helper'

class BaseTest < Minitest::Test
  def test_lists_flips
    WebMock.enable_net_connect!
    refute_nil(Base.new(Dynamo.new.aws).flips)
  end

  def test_tries_to_take_absent_endpoint
    WebMock.enable_net_connect!
    assert_raises(Base::EndpointNotFound) do
      Base.new(Dynamo.new.aws).take('absent')
    end
  end

  def test_ping_increments_total_pings
    WebMock.enable_net_connect!
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
    assert(pings.count > initial)
    remove_request_stub(first_stub)
    remove_request_stub(second_stub)
  end
end
