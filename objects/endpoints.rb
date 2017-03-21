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

require_relative 'endpoint'

#
# Endpoints of a user
#
class Endpoints
  def initialize(aws, user)
    @aws = aws
    @user = user
  end

  def add(uri)
    @aws.put_item(
      table_name: 'sn-endpoints',
      item: {
        'login' => @user,
        'uri' => uri,
        'active' => 'yes',
        'created' => Time.now.to_i,
        'hostname' => URI.parse(uri).host.gsub(/^www\./, ''),
        'pings' => 0,
        'failures' => 0,
        'expires' => 0
      }
    )
  end

  def del(uri)
    @aws.delete_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => @user,
        'uri' => uri
      }
    )
  end

  def list
    @aws.query(
      table_name: 'sn-endpoints',
      select: 'ALL_ATTRIBUTES',
      limit: 50,
      expression_attribute_values: {
        ':v' => @user
      },
      key_condition_expression: 'login = :v'
    ).items.map { |i| Endpoint.new(@aws, i) }
  end
end
