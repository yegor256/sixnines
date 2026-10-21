# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'timeout'
require_relative '../internal_error_response'

#
# Response that times out.
#
# The response is received in a separate thread, which is killed
# when the period expires. Timeout.timeout is not used here, because
# when it is nested with the timeout that Net::HTTP sets around
# its TCP connect, both of them may fire together, and the second
# exception escapes into the code that runs after the check.
#
class TimedoutResponse
  def initialize(period)
    @period = period
  end

  def check(response)
    worker = Thread.new do
      Thread.current.report_on_exception = false
      response.receive
    end
    raise Timeout::Error unless worker.join(@period)
    worker.value
  rescue Timeout::Error
    worker&.kill
    InternalErrorResponse.new(
      "The request timed out after #{@period} seconds."
    ).receive
  end
end
