# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'net/http'
require_relative '../internal_error_from_exception_response'

#
# Response checked for socket error
#
class SocketErrorResponse
  def initialize(tries)
    @tries = tries
  end

  def check(response)
    response.receive
  rescue SocketError => e
    retry unless (@tries -= 1).zero?
    InternalErrorFromExceptionResponse.new(e).receive
  end
end
