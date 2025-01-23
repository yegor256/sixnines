# frozen_string_literal: true

# Copyright (c) 2017-2025 Yegor Bugayenko
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
