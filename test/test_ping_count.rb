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
require_relative '../objects/ping_count'
require_relative '../objects/dynamo'

class PingCountTest < Test::Unit::TestCase
end

class StartFromTest < PingCountTest
  NUMBER = 10

  def setup
    @aws = Dynamo.new.aws
    PingCount.new(@aws).start_from(NUMBER)
    @actual = @aws.get_item(
      table_name: 'sn-counts',
      key: { 'id' => 'ping-count' }
    )[:item]
  end

  def teardown
    @actual = @aws.delete_item(
      table_name: 'sn-counts',
      key: { 'id' => 'ping-count' }
    )
  end

  def test_count_number
    assert_equal(NUMBER, @actual['count'])
  end

  def test_description
    assert_equal('Number of pings done so far.', @actual['description'])
  end
end

class CountTest < PingCountTest
  NUMBER = 15

  def setup
    @aws = Dynamo.new.aws
    PingCount.new(@aws).start_from(NUMBER)
    @count = PingCount.new(@aws).count
  end

  def teardown
    @actual = @aws.delete_item(
      table_name: 'sn-counts',
      key: { 'id' => 'ping-count' }
    )
  end

  def test_number
    assert_equal(NUMBER, @count)
  end

  def test_integer
    assert_equal(NUMBER.to_s, @count.to_s)
  end
end

class IncrementTest < PingCountTest
  NUMBER = 2
  TIMES = 5

  def setup
    @aws = Dynamo.new.aws
    PingCount.new(@aws).start_from(NUMBER)
    PingCount.new(@aws).increment(TIMES)
  end

  def teardown
    @actual = @aws.delete_item(
      table_name: 'sn-counts',
      key: { 'id' => 'ping-count' }
    )
  end

  def test_increment
    assert_equal(NUMBER + TIMES, PingCount.new(@aws).count)
  end
end
