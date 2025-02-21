# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'backtrace'
require_relative '../response'

#
# Check for all errors.
#
class BrokenResponse
  def check(response)
    response.receive
  rescue StandardError => e
    Response.new(
      500,
      e.message,
      Backtrace.new(e).to_s
    ).receive
  end
end
