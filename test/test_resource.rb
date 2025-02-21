# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'test/unit'
require 'rack/test'
require 'zlib'
require_relative 'fake_server'
require_relative '../objects/resource'

class ResourceTest < Test::Unit::TestCase
  def test_pings_valid_uri
    port = FakeServer.new.start(200)
    assert_equal(
      200,
      Resource.new(URI.parse("http://127.0.0.1:#{port}/")).take[0]
    )
  end

  def test_pings_broken_uri
    assert_not_equal(
      200,
      Resource.new(
        URI.parse('http://broken-uri-for-sure.io')
      ).take[0]
    )
  end

  def test_timeout
    stub = stub_request(:any, 'www.bbc.com').to_return do
      sleep(10)
      'Welcome to BBC.com'
    end
    assert_equal(
      [500, '', 'The request timed out after 5 seconds.'],
      Resource.new(URI.parse('http://www.bbc.com')).take
    )
    remove_request_stub(stub)
  end

  def test_bad_compression
    stub = stub_request(:any, 'www.wikipedia.org').to_return do
      raise Zlib::BufError, 'buffer error', caller
    end
    assert_equal(
      500,
      Resource.new(URI.parse('http://www.wikipedia.org')).take[0]
    )
    remove_request_stub(stub)
  end

  def test_network_unreachable
    stub = stub_request(:any, 'www.microsoft.com').to_return do
      raise Errno::ENETUNREACH, 'network unreachable', caller
    end
    assert_equal(
      [500, '', 'Network unreachable.'],
      Resource.new(URI.parse('http://www.microsoft.com')).take
    )
    remove_request_stub(stub)
  end

  def test_other_error
    stub = stub_request(:any, 'www.microsoft.com').to_return do
      raise 'oops'
    end
    assert_equal(
      'oops',
      Resource.new(URI.parse('http://www.microsoft.com')).take[1]
    )
    remove_request_stub(stub)
  end
end
