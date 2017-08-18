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
require_relative 'responses/zlib_buffer_error_response'
require_relative 'responses/socket_error_response'
require_relative 'responses/timedout_response'
require_relative 'responses/http_response'
require_relative 'responses/network_unreachable_response'
require_relative 'responses/proxy_authentication_required_response'

#
# Single web resource.
#
class Resource
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
    ZlibBufferErrorResponse.new(
      ProxyAuthenticationRequiredResponse.new(
        SocketErrorResponse.new(
          TimedoutResponse.new(
            NetworkUnreachableResponse.new(HTTPResponse.new(http, req)),
            5
          ),
          3
        )
      )
    ).receive
  end
end
