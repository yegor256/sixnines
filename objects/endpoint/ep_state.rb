# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

#
# State of endpoint
#
class EpState
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def to_b
    @endpoint.to_h[:up]
  end

  def to_s
    to_b ? 'UP' : 'DOWN'
  end

  def to_html
    color = @endpoint.to_h[:up] ? 'green' : 'red'
    "<span style='color:#{color}'>#{self}</span>"
  end
end
