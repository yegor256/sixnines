# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'net/http'
require_relative '../internal_error_response'

#
# Response checked for network unreachable error
#
class NetworkUnreachableResponse
  def check(response)
    response.receive
  rescue Errno::ENETUNREACH
    InternalErrorResponse.new('Network unreachable.').receive
  end
end
