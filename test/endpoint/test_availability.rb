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
require_relative '../../objects/endpoint/ep_availability'

class AvailabilityTest < Test::Unit::TestCase
  def test_renders_numbers
    [
      { pings: 0, failures: 0, avlbl: '00.0000%' },
      { pings: 100, failures: 0, avlbl: '99.0000%' },
      { pings: 100, failures: 95, avlbl: '05.0000%' },
      { pings: 1_000, failures: 0, avlbl: '99.9000%' },
      { pings: 10_000, failures: 5, avlbl: '99.9500%' },
      { pings: 10_000, failures: 0, avlbl: '99.9900%' },
      { pings: 10_568, failures: 2, avlbl: '99.9810%' },
      { pings: 1_000_000, failures: 0, avlbl: '99.9999%' }
    ].each do |a|
      endpoint = Class.new do
        def initialize(p, f)
          @p = p
          @f = f
        end

        def to_h
          { pings: @p, failures: @f }
        end
      end.new(a[:pings], a[:failures])
      assert_equal(a[:avlbl], EpAvailability.new(endpoint).short)
    end
  end
end
