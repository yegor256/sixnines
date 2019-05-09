# frozen_string_literal: true

# Copyright (c) 2017-2019 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
end
