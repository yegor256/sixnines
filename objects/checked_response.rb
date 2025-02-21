# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'net/http'

#
# Response checked for errors
#
class CheckedResponse
  def initialize(response, checks)
    @response = response
    @checks = checks
  end

  def receive
    if @checks.empty?
      @response.receive
    else
      @checks[0].check(
        CheckedResponse.new(
          @response,
          @checks[1..@checks.length]
        )
      )
    end
  end
end
