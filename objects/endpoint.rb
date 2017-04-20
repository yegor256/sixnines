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
require 'timeout'
require 'net/http'
require_relative 'endpoint/ep_uri'
require_relative 'endpoint/ep_state'
require_relative 'endpoint/ep_availability'
require_relative 'endpoint/ep_badge'
require_relative 'endpoint/ep_graph'

#
# Single endpoint
#
class Endpoint
  # Cached endpoint
  class Cached
    def initialize(ep)
      @ep = ep
      @history = nil
    end

    def to_h
      @ep.to_h
    end

    def history
      @history ||= @ep.history
    end

    def ping
      @ep.ping
    end

    def fetch
      @ep.fetch
    end
  end

  def initialize(aws, item)
    @aws = aws
    @item = item
  end

  def to_h
    h = {
      uri: URI.parse(@item['uri']),
      favicon: @item['favicon'] ? URI.parse(@item['favicon']) : nil,
      login: @item['login'],
      id: @item['id'],
      hostname: @item['hostname'],
      failures: @item['failures'].to_i,
      pings: @item['pings'].to_i,
      up: @item['state'] == 'up',
      created: Time.at(@item['created']),
      log: @item['log']
    }
    h[:updated] = Time.at(@item['updated']) if @item['updated']
    h[:flipped] = Time.at(@item['flipped']) if @item['flipped']
    h[:expires] = Time.at(@item['expires']) if @item['expires']
    h
  end

  def history
    @aws.query(
      table_name: 'sn-pings',
      select: 'SPECIFIC_ATTRIBUTES',
      projection_expression: '#time, msec, code',
      limit: 1000,
      scan_index_forward: false,
      expression_attribute_names: {
        '#time' => 'time'
      },
      expression_attribute_values: {
        ':u' => @item['uri'],
        ':t' => (Time.now - 1000 * 60).to_i
      },
      key_condition_expression: 'uri = :u and #time > :t'
    ).items.map do |i|
      {
        time: Time.at(i['time']),
        msec: i['msec'].to_i,
        code: i['code'].to_i
      }
    end
  end

  def ping
    start = Time.now
    res, log = fetch
    h = to_h
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
    update = [
      'updated = :t',
      'expires = :e',
      'favicon = :f',
      'pings = pings + :o',
      '#state = :s'
    ]
    ean = {
      '#state' => 'state'
    }
    eav = {
      ':s' => up ? 'up' : 'down',
      ':o' => 1,
      ':t' => Time.now.to_i,
      ':e' => (Time.now + 60).to_i, # ping again in 60 seconds
      ':f' => favicon(res.body).to_s
    }
    update << 'failures = failures + :o' unless up
    update << 'flipped = :t' unless up == h[:up]
    unless up
      update << '#log = :g'
      ean['#log'] = 'log'
      eav[':g'] = "#{Time.now}\n\n#{log}"
    end
    @aws.update_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => h[:login],
        'uri' => h[:uri].to_s
      },
      expression_attribute_names: ean,
      expression_attribute_values: eav,
      update_expression: 'set ' + update.join(', ')
    )
    yield(up, self) if block_given? && up != h[:up]
    "#{h[:uri]}: #{res.code}"
  end

  private

  def fetch
    h = to_h
    http = Net::HTTP.new(h[:uri].host, h[:uri].port)
    if h[:uri].scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    req = Net::HTTP::Get.new(h[:uri].request_uri)
    req['User-Agent'] = 'SixNines.io (not Firefox, Chrome, or Safari)'
    tries = 3
    begin
      res = Timeout.timeout(5) do
        http.request(req)
      end
      [
        res,
        to_text(req, res)
      ]
    rescue SocketError => e
      retry unless (tries -= 1).zero?
      [
        Class.new do
          def code
            '500'
          end

          def body
            ''
          end
        end.new,
        "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
      ]
    end
  end

  def to_text(req, res)
    "#{req.method} #{req.path} HTTP/1.1\n\
#{headers(req)}\n#{body(req.body)}\n\n\
HTTP/#{res.http_version} #{res.code} #{res.message}\n\
#{headers(res)}\n#{body(res.body)}"
  end

  def headers(headers)
    headers.to_hash.map { |k, v| v.map { |h| k + ': ' + h } }.join("\n")
  end

  def body(body)
    body.nil? ? '' : body.strip.gsub(/^(.{200,}?).*$/m, '\1...')
  end

  def favicon(body)
    xml = Nokogiri::HTML(body)
    links = xml.xpath('/html/head/link[@rel="shortcut icon"]/@href')
    if links.empty?
      URI.parse("http://#{to_h[:uri].host}/favicon.ico")
    else
      uri = URI.parse(links[0])
      uri = URI.parse("http://#{to_h[:uri].host}#{uri}") unless uri.absolute?
      uri
    end
  rescue => _
    URI.parse('localhost')
  end
end
