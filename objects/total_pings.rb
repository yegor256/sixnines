# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'concurrent'

#
# Total pings
#
class TotalPings
  def initialize(count)
    @count = Concurrent::AtomicFixnum.new(count)
  end

  def increment(times)
    @count.increment(times)
  end

  def count
    @count.value.to_i
  end
end
