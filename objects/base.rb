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

  def ping
    reports = []
    loop do
      list = @aws.query(
        table_name: 'sn-endpoints',
        index_name: 'expires',
        select: 'ALL_ATTRIBUTES',
        limit: 10,
        expression_attribute_values: {
          ':h' => 'yes',
          ':r' => Time.now.to_i
        },
        key_condition_expression:
          'active=:h and (expires < :r or attribute_not_exists(expires))'
      ).items.map { |i| Endpoint.new(@aws, i['uri']) }
      break if list.empty?
      @aws.batch_write_item(
        request_items: {
          'sn-pings' => list.map(&:ping).map do |d|
            reports << "#{d.uri}: #{d.code}/#{d.msec}"
            {
              put_request: {
                item: {
                  'uri' => d.uri,
                  'time' => d.time.to_i,
                  'local' => d.local,
                  'remote' => d.remote,
                  'msec' => d.msec,
                  'code' => d.code,
                  'delete_on' => Time.now + (24 * 60 * 60)
                }
              }
            }
          end,
          'sn-endpoints' => [
          ]
        }
      )
    end
    "Done (#{reports.size} endpoints):\n" + reports.join("\n")
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
    ).items.map { |i| Endpoint.new(@aws, i['uri']) }
  end

  def flips
    @aws.query(
      table_name: 'sn-endpoints',
      index_name: 'flips',
      select: 'ALL_ATTRIBUTES',
      limit: 10,
      expression_attribute_values: {
        ':h' => 'yes'
      },
      key_condition_expression: 'active=:h'
    ).items.map { |i| Endpoint.new(@aws, i['uri']) }
  end

  def endpoints(user)
    Endpoints.new(@aws, user)
  end
end
