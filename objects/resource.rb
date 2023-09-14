# frozen_string_literal: true

# Copyright (c) 2017-2023 Yegor Bugayenko
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

require 'net/http'
require 'openssl'
require_relative 'http_response'
require_relative 'checked_response'
require_relative 'checks/zlib_buffer_error_response'
require_relative 'checks/socket_error_response'
require_relative 'checks/timedout_response'
require_relative 'checks/network_unreachable_response'
require_relative 'checks/broken_response'

#
# Single web resource.
#
class Resource
  def initialize(uri)
    @uri = uri
  end

  def take(host = nil, port = nil)
    raise "Resource URI can't be nil" if @uri.nil?
    http = Net::HTTP.new(@uri.host, @uri.port, host, port)
    if @uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    req = Net::HTTP::Get.new(@uri.request_uri)
    req['User-Agent'] = 'SixNines.io (not Firefox, Chrome, or Safari)'
    CheckedResponse.new(
      HTTPResponse.new(http, req),
      [
        BrokenResponse.new,
        ZlibBufferErrorResponse.new,
        SocketErrorResponse.new(3),
        TimedoutResponse.new(5),
        NetworkUnreachableResponse.new
      ]
    ).receive
  end
end
