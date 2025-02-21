# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'json'

#
# Data of endpoint
#
class EpData
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def to_json(*_args)
    JSON.generate(@endpoint.to_h)
  end
end
