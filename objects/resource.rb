# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
