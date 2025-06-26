# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'test__helper'
require_relative '../objects/resource'
require_relative '../objects/proxied_resource'

class ProxiedResourceTest < Minitest::Test
  def test_pings_valid_uri
    WebMock.enable_net_connect!
    port = FakeServer.new.start(200)
    proxy = FakeServer.new.start(200)
    assert_equal(
      200,
      ProxiedResource.new(
        Resource.new(URI.parse("http://127.0.0.1:#{port}/")),
        [
          '',
          "127.0.0.1:#{proxy}"
        ]
      ).take[0]
    )
  end

  def test_pings_valid_uri_without_proxy
    WebMock.enable_net_connect!
    port = FakeServer.new.start(200)
    assert_equal(
      200,
      ProxiedResource.new(
        Resource.new(URI.parse("http://127.0.0.1:#{port}/"))
      ).take[0]
    )
  end

  def test_pings_invalid_uri
    WebMock.enable_net_connect!
    proxy = FakeServer.new.start(500)
    refute_equal(
      200,
      ProxiedResource.new(
        Resource.new(URI.parse('http://www.definitely-invalid-url-yegor.com')),
        ["127.0.0.1:#{proxy}"]
      ).take[0]
    )
  end
end
