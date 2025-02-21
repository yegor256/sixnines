# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'uri'
require 'timeout'
require 'net/http'
require 'openssl'
require_relative '../objects/resource'

#
# Resource whose pings are counted
#
class CountedResource
  def initialize(count, resource)
    @count = count
    @resource = resource
  end

  def take(host = nil, port = nil)
    take = @resource.take(host, port)
    @count.increment(1)
    take
  end
end
