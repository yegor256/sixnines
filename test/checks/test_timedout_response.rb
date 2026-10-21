# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'net/http'
require_relative '../../objects/checks/timedout_response'
require_relative '../test__helper'

#
# Response that hangs while connecting, the way Net::HTTP does on Ruby 3.3
#
class StuckResponse
  def initialize(period)
    @period = period
  end

  def receive
    Timeout.timeout(@period, Net::OpenTimeout) { loop { nil } }
  end
end

class TimedoutResponseTest < Minitest::Test
  def test_reports_timeout_of_stuck_response
    assert_equal(
      'The request timed out after 1 seconds.',
      TimedoutResponse.new(1).check(StuckResponse.new(1))[2],
      'The stuck response was not reported as timed out'
    )
  end

  def test_does_not_leak_inner_timeout_after_check
    TimedoutResponse.new(1).check(StuckResponse.new(1))
    start = Time.now
    assert(
      loop { break true if Time.now - start > 2 },
      'The inner timeout leaked out of the check'
    )
  end
end
