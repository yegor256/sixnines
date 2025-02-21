# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'internal_error_response'

#
# Response coming from an error caused by an exception
#
class InternalErrorFromExceptionResponse
  def initialize(exception)
    @e = exception
  end

  def receive
    InternalErrorResponse.new(
      "#{@e.class}: #{@e.message}\n\t#{@e.backtrace.join("\n\t")}"
    ).receive
  end
end
