# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'test__helper'
require_relative '../objects/endpoints'

class EndpointsTest < Minitest::Test
  def test_creates_endpoint
    WebMock.enable_net_connect!
    eps = Endpoints.new(Dynamo.new.aws, 'yegor256-endpoints')
    uri = 'http://www.sixnines.io'
    eps.add(uri)
    assert_equal(1, eps.list.size)
    eps.del(uri)
  end
end
