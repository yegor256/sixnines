# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'timeout'
require_relative '../internal_error_response'

#
# Response that times out
#
class TimedoutResponse
  def initialize(period)
    @period = period
  end

  def check(response)
    Timeout.timeout(@period) { response.receive }
  rescue Timeout::Error
    InternalErrorResponse.new(
      "The request timed out after #{@period} seconds."
    ).receive
  end
end
