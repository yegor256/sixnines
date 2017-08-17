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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#
# Ping count
#
class PingCount
  def initialize(aws)
    @aws = aws
  end

  def start_from(count)
    @aws.put_item(
      table_name: 'sn-counts',
      item: {
        id: 'ping-count',
        count: count,
        description: 'Number of pings done so far.'
      }
    )
  end

  def increment(times)
    @aws.update_item(
      table_name: 'sn-counts',
      key: { 'id' => 'ping-count' },
      update_expression: 'set #count = #count + :increment',
      expression_attribute_names: { '#count' => 'count' },
      expression_attribute_values: { ':increment' => times }
    )
  end

  def count
    @aws.get_item(
      table_name: 'sn-counts',
      key: { 'id' => 'ping-count' }
    )[:item]['count']
  end
end
