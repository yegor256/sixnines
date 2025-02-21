# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

#
# Availability of endpoint
#
class EpAvailability
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def to_f
    h = @endpoint.to_h
    [
      (100 * (1 - (nz(h[:failures].to_f) / nz(h[:pings].to_f)))),
      99.9999
    ].min.round(Math.log10(nz(h[:pings])).to_i - 1)
  end

  def to_s
    format('%07.04f', to_f)
  end

  def short
    "#{self}%"
  end

  def full
    h = @endpoint.to_h
    "#{h[:failures]}/#{h[:pings]}"
  end

  def nz(num)
    [num, 1].max
  end
end
