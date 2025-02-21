# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'response'

#
# Response coming from an internal error
#
class InternalErrorResponse
  def initialize(message)
    @message = message
  end

  def receive
    Response.new(500, '', @message).receive
  end
end
