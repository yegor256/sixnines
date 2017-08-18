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
require_relative 'response'

#
# HTTP response
#
class HTTPResponse
  def initialize(http, request)
    @http = http
    @request = request
  end

  def receive
    response = @http.request(@request)
    Response.new(
      response.code.to_i,
      response.body,
      to_text(@request, response)
    ).receive
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
