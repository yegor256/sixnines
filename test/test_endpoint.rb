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
require_relative '../objects/endpoint'

class EndpointTest < Test::Unit::TestCase
  def test_pings_valid_uri
    ep = Endpoint.new(
      nil,
      'uri' => 'http://www.sixnines.io',
      'created' => 1_490_177_388
    )
    res, log = ep.fetch
    assert_equal('200', res.code)
    assert(log.include?('HTTP/1.1'))
  end

  def test_pings_broken_uri
    ep = Endpoint.new(
      nil,
      'uri' => 'http://www.sixnines-broken-uri.io',
      'created' => 1_490_177_365
    )
    res, _ = ep.fetch
    assert_equal('500', res.code)
  end
end
