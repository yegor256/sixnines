# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'

#
# One command exec
#
class Exec
  def initialize(*rest)
    @cmd = rest.join(' ')
  end

  def run
    stdout = `(#{@cmd}) 2>&1`
    status = $CHILD_STATUS.to_i
    return stdout if status.zero?
    puts @cmd
    raise "#{@cmd}: #{status} (not zero):\n#{stdout}"
  end
end
