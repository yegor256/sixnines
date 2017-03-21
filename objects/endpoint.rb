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
require_relative 'endpoint/ep_uri'
require_relative 'endpoint/ep_state'
require_relative 'endpoint/ep_availability'
require_relative 'endpoint/ep_badge'

#
# Single endpoint
#
class Endpoint
  def initialize(aws, item)
    @aws = aws
    @item = item
  end

  def to_h
    h = {
      uri: URI.parse(@item['uri']),
      hostname: @item['hostname'],
      failures: @item['failures'].to_i,
      pings: @item['pings'].to_i,
      up: @item['state'] == 'up',
      created: Time.at(@item['created'])
    }
    h[:updated] = Time.at(@item['updated']) if @item['updated']
    h[:flipped] = Time.at(@item['flipped']) if @item['flipped']
    h[:expires] = Time.at(@item['expires']) if @item['expires']
    h
  end

  def ping
    h = to_h
    http = Net::HTTP.new(h[:uri].host, h[:uri].port)
    if h[:uri].scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http.read_timeout = 5
    http.continue_timeout = 5
    req = Net::HTTP::Head.new(h[:uri].request_uri)
    req['User-Agent'] = 'sixnines.io'
    start = Time.now
    res = http.request(req)
    puts "ping #{res.code}: #{h[:uri]}"
    @aws.put_item(
      table_name: 'sn-pings',
      item: {
        uri: h[:uri].to_s,
        code: res.code.to_i,
        time: Time.now.to_i,
        msec: ((Time.now - start) * 1000).to_i,
        local: 'unknown',
        remote: 'unknown',
        delete_on: (Time.now + (24 * 60 * 60)).to_i
      }
    )
    up = res.code == '200'
    @aws.update_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => h[:login],
        'uri' => h[:uri].to_s
      },
      expression_attribute_names: {
        '#state' => 'state'
      },
      expression_attribute_values: {
        ':s' => up ? 'up' : 'down',
        ':o' => 1,
        ':t' => Time.now.to_i,
        ':e' => (Time.now + (5 * 60)).to_i, # ping again in 5 minutes
      },
      update_expression: 'set updated = :t, expires = :e, pings = pings + :o' +
        (up ? '' : ', failures = failures + :o') +
        (up == h[:up] ? '' : ', flipped = :t, #state = :s')
    )
    "#{h[:uri]}: #{res.code}"
  end
end
