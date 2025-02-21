# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'test/unit'
require 'rack/test'
require_relative '../../objects/endpoint/ep_availability'

class AvailabilityTest < Test::Unit::TestCase
  def test_renders_numbers
    [
      { pings: 0, failures: 0, avlbl: '00.0000%' },
      { pings: 100, failures: 0, avlbl: '99.0000%' },
      { pings: 100, failures: 95, avlbl: '05.0000%' },
      { pings: 1_000, failures: 0, avlbl: '99.9000%' },
      { pings: 10_000, failures: 5, avlbl: '99.9500%' },
      { pings: 10_000, failures: 0, avlbl: '99.9900%' },
      { pings: 10_568, failures: 2, avlbl: '99.9810%' },
      { pings: 1_000_000, failures: 0, avlbl: '99.9999%' }
    ].each do |a|
      endpoint = Class.new do
        def initialize(pings, failures)
          super()
          @pings = pings
          @failures = failures
        end

        def to_h
          { pings: @pings, failures: @failures }
        end
      end.new(a[:pings], a[:failures])
      assert_equal(a[:avlbl], EpAvailability.new(endpoint).short)
    end
  end
end
