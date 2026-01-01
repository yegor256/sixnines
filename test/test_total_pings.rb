# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'test__helper'
require_relative '../objects/total_pings'

class TotalPingsTest < Minitest::Test
  def test_count
    count = 5
    assert_equal(count, TotalPings.new(count).count)
  end

  def test_increment
    initial = 7
    increase = 3
    total = TotalPings.new(initial)
    total.increment(increase)
    assert_equal(
      initial + increase,
      total.count
    )
  end

  def test_integer
    count = 9
    assert_equal(count.to_s, TotalPings.new(count).count.to_s)
  end
end
