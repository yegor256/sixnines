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
require_relative '../objects/counted_resource'
require_relative '../objects/resource'
require_relative '../objects/dynamo'
require_relative '../objects/total_pings'

class CountedResourceTest < Test::Unit::TestCase
  START = 5
  PINGS = 3

  def test_increments_on_ping
    stub = stub_request(:any, 'www.ebay.com')
    count = TotalPings.new(START)
    resource = CountedResource.new(
      count,
      Resource.new(URI.parse('http://www.ebay.com'))
    )
    PINGS.times do
      resource.take
    end
    assert_equal(START + PINGS, count.count)
    remove_request_stub(stub)
  end
end
