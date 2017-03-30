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

require_relative 'endpoints'

#
# Base
#
class Base
  def initialize(aws)
    @aws = aws
  end

  def ping(&b)
    @aws.query(
      table_name: 'sn-endpoints',
      index_name: 'expires',
      select: 'ALL_ATTRIBUTES',
      limit: 10,
      expression_attribute_values: {
        ':h' => 'yes',
        ':r' => Time.now.to_i
      },
      key_condition_expression: 'active=:h and expires < :r'
    ).items.map { |i| Endpoint.new(@aws, i) }.map { |e| e.ping(b) }.join("\n")
  end

  def find(query)
    @aws.query(
      table_name: 'sn-endpoints',
      index_name: 'hostnames',
      select: 'ALL_ATTRIBUTES',
      limit: 10,
      expression_attribute_values: {
        ':h' => 'yes',
        ':r' => query
      },
      key_condition_expression: 'active=:h and begins_with(hostname,:r)'
    ).items.map { |i| Endpoint.new(@aws, i) }
  end

  def take(id)
    Endpoint.new(
      @aws,
      @aws.query(
        table_name: 'sn-endpoints',
        index_name: 'unique',
        select: 'ALL_ATTRIBUTES',
        limit: 1,
        expression_attribute_values: {
          ':h' => id
        },
        key_condition_expression: 'id=:h'
      ).items[0]
    )
  end

  def flips
    @aws.query(
      table_name: 'sn-endpoints',
      index_name: 'flips',
      scan_index_forward: false,
      select: 'ALL_ATTRIBUTES',
      limit: 10,
      expression_attribute_values: {
        ':h' => 'yes'
      },
      key_condition_expression: 'active=:h'
    ).items.map { |i| Endpoint.new(@aws, i) }
  end

  def endpoints(user)
    Endpoints.new(@aws, user)
  end
end
