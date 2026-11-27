# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'test__helper'
require_relative 'fake_server'
require_relative '../objects/base'
require_relative '../objects/endpoint'
require_relative '../objects/endpoints'
require_relative '../objects/dynamo'
require_relative '../objects/total_pings'

class EndpointTest < Minitest::Test
  def test_pings_valid_uri
    WebMock.enable_net_connect!
    port = FakeServer.new.start(200)
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(
      "http://127.0.0.1:#{port}/"
    )
    ep = Base.new(dynamo).take(id)
    ping = ep.ping(TotalPings.new(0))
    assert_includes(ping, '200')
  end

  def test_pings_broken_uri
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(
      'http://www.sixnines-broken-uri.io'
    )
    ep = Base.new(dynamo).take(id)
    ping = ep.ping(TotalPings.new(1))
    refute_includes(ping, '200')
  end

  def test_pings_via_broken_proxy
    WebMock.enable_net_connect!
    port = FakeServer.new.start(407)
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(
      'http://www.the-address-that-does-not-exist-for-sure.com'
    )
    ep = Base.new(dynamo).take(id)
    ping = ep.ping(TotalPings.new(1), ["127.0.0.1:#{port}"])
    assert_includes(ping, '200')
  end

  def test_flushes
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(
      'http://broken-url'
    )
    ep = Base.new(dynamo).take(id)
    ep.ping(TotalPings.new(2))
    refute_nil(Base.new(dynamo).take(id).to_h[:log])
    ep.flush
    refute(Base.new(dynamo).take(id).to_h[:log])
  end

  def test_ping_success_is_recorded_in_history
    WebMock.enable_net_connect!
    port = FakeServer.new.start(200)
    dynamo = Dynamo.new.aws
    uri = "http://127.0.0.1:#{port}/"
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(uri)
    eps = Endpoints.new(dynamo, 'yegor256-endpoint')
    Base.new(dynamo).take(id).ping(TotalPings.new(0))
    assert_equal(1, eps.successful_pings(uri))
    eps.del(uri)
  end

  def test_ping_failure_is_not_recorded_as_success
    WebMock.enable_net_connect!
    port = FakeServer.new.start(500)
    dynamo = Dynamo.new.aws
    uri = "http://127.0.0.1:#{port}/"
    id = Endpoints.new(dynamo, 'yegor256-endpoint').add(uri)
    eps = Endpoints.new(dynamo, 'yegor256-endpoint')
    Base.new(dynamo).take(id).ping(TotalPings.new(0))
    h = Base.new(dynamo).take(id).to_h
    assert_equal(1, h[:pings], 'The failed ping must be counted as a ping')
    assert_equal(1, h[:failures], 'The failed ping must be counted as a failure')
    assert_equal(
      0,
      eps.successful_pings(uri),
      'A failed ping must not count as a success'
    )
    eps.del(uri)
  end

  def test_increments_ping_count
    WebMock.enable_net_connect!
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

  def test_dynamo_operations_dont_timeout_after_slow_http_request
    WebMock.enable_net_connect!
    port = FakeServer.new.start(200, 4)
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'yegor256-slow-endpoint').add(
      "http://127.0.0.1:#{port}/"
    )
    ep = Base.new(dynamo).take(id)
    result = Timeout.timeout(10) { ep.ping(TotalPings.new(0)) }
    assert_includes(
      result,
      '200',
      'expected ping to complete without timeout leak into DynamoDB'
    )
  end
end
