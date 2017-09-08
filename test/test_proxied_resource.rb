# encoding: utf-8
#
# Copyright (c) 2017 Yegor Bugayenko
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
require_relative '../objects/resource'
require_relative '../objects/proxied_resource'

class ProxiedResourceTest < Test::Unit::TestCase
  def test_pings_valid_uri
    port = FakeServer.new.start(200)
    assert_equal(
      200,
      ProxiedResource.new(
        Resource.new(URI.parse("http://127.0.0.1:#{port}/")),
        [
          '',
          '216.230.229.34:60099'
        ]
      ).take[0]
    )
  end

  def test_pings_valid_uri_without_proxy
    port = FakeServer.new.start(200)
    assert_equal(
      200,
      ProxiedResource.new(
        Resource.new(URI.parse("http://127.0.0.1:#{port}/"))
      ).take[0]
    )
  end

  def test_pings_invalid_uri
    assert_not_equal(
      200,
      ProxiedResource.new(
        Resource.new(URI.parse('http://www.definitely-invalid-url-yegor.com')),
        ['216.230.229.34:60099']
      ).take[0]
    )
  end
end
