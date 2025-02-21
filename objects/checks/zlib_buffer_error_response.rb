# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'net/http'
require_relative '../internal_error_from_exception_response'

#
# Response checked for Zlib compression buffer error
#
class ZlibBufferErrorResponse
  def check(response)
    response.receive
  rescue Zlib::BufError => e
    InternalErrorFromExceptionResponse.new(e).receive
  end
end
