# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

#
# Response
#
class Response
  def initialize(code, body, log)
    @code = code
    @body = body
    @log = log
  end

  def receive
    [@code.to_i, @body, @log]
  end
end
