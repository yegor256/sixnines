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

require 'uri'

#
# Single endpoint
#
class Endpoint
  def initialize(aws, item)
    @aws = aws
    @item = item
  end

  def uri
    URI.parse(@item['uri'])
  end

  def state
    @item['state']
  end

  def flipped
    Time.at(@item['flipped'])
  end

  def avt
    format(
      '%.04f',
      if @item['pings'].zero?
        0
      else
        100 * (1 - @item['failures'] / @item['pings'])
      end
    )
  end

  def ping
    u = uri
    http = Net::HTTP.new(u.host, u.port)
    if u.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http.read_timeout = 5
    http.continue_timeout = 5
    req = Net::HTTP::Head.new(u.request_uri)
    req['User-Agent'] = 'sixnines.io'
    start = Time.now
    res = http.request(req)
    puts "ping #{res.code}: #{u}"
    @aws.put_item(
      table_name: 'sn-pings',
      item: {
        uri: u.to_s,
        code: res.code.to_i,
        time: Time.now.to_i,
        msec: ((Time.now - start) * 1000).to_i,
        local: 'unknown',
        remote: 'unknown',
        delete_on: (Time.now + (24 * 60 * 60)).to_i
      }
    )
    stt = res.code == '200' ? 'up' : 'down'
    @aws.update_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => @item['login'],
        'uri' => u.to_s
      },
      expression_attribute_names: {
        '#state' => 'state'
      },
      expression_attribute_values: {
        ':s' => stt,
        ':o' => 1,
        ':t' => Time.now.to_i,
        ':e' => (Time.now + (5 * 60)).to_i, # ping again in 5 minutes
      },
      update_expression: 'set updated = :t, expires = :e, pings = pings + :o' +
        (stt == 'up' ? '' : ', failures = failures + :o') +
        (stt == state ? '' : ', flipped = :t, #state = :s')
    )
    "#{u}: #{res.code}"
  end
end
