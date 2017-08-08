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
require 'openssl'

#
# Single web resource.
#
class Resource
  PERIOD = 5

  def initialize(uri)
    @uri = uri
  end

  def take(host = nil, port = nil)
    http = Net::HTTP.new(@uri.host, @uri.port, host, port)
    if @uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    req = Net::HTTP::Get.new(@uri.request_uri)
    req['User-Agent'] = 'SixNines.io (not Firefox, Chrome, or Safari)'
    tries = 3
    begin
      res = Timeout.timeout(PERIOD) do
        http.request(req)
      end
      [res.code.to_i, res.body, to_text(req, res)]
    rescue Timeout::Error
      [500, '', "The request timed out after #{PERIOD} seconds."]
    rescue SocketError => e
      retry unless (tries -= 1).zero?
      [500, '', "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"]
    end
  end

  private

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
end
