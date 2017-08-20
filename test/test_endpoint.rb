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
require_relative '../objects/base'
require_relative '../objects/endpoint'
require_relative '../objects/endpoints'
require_relative '../objects/dynamo'
require_relative '../objects/total_pings'

class EndpointTest < Test::Unit::TestCase
  def test_pings_valid_uri
    sites = [
      'http://www.yegor256.com',
      'https://twitter.com/yegor256',
      'http://ru.yegor256.com/2017-06-29-activists.html'
    ]
    dynamo = Dynamo.new.aws
    sites.each do |s|
      id = Endpoints.new(dynamo, 'yegor256-endpoint').add(s)
      ep = Base.new(dynamo).take(id)
      ping = ep.ping(TotalPings.new(0))
      assert(ping.end_with?('200'), ping)
    end
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
    initial = 3
    first_proxy = 'my-proxy.com:8080'
    second_proxy = 'my-other-proxy.com:3000'
    first_stub = stub_request(:any, first_proxy)
    second_stub = stub_request(:any, second_proxy)
    dynamo = Dynamo.new.aws
    id = Endpoints.new(dynamo, 'pdacostaporto-endpoint').add(
      'http://www.siniestromuppet.org.uy'
    )
    ep = Base.new(dynamo).take(id)
    pings = TotalPings.new(initial)
    ep.ping(pings, [first_proxy, second_proxy])
    assert_equal(initial + 1, pings.count)
    remove_request_stub(first_stub)
    remove_request_stub(second_stub)
  end
end
