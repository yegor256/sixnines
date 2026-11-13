# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
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

  def test_counts_no_successful_pings_of_fresh_endpoint
    WebMock.enable_net_connect!
    eps = Endpoints.new(Dynamo.new.aws, 'yegor256-pings')
    uri = 'http://www.sixnines.io'
    eps.add(uri)
    assert_equal(0, eps.successful_pings(uri))
    eps.del(uri)
  end

  def test_counts_successful_pings_minus_failures
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    eps = Endpoints.new(dynamo, 'yegor256-pings')
    uri = 'http://www.sixnines.io'
    eps.add(uri)
    dynamo.update_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => 'yegor256-pings',
        'uri' => uri
      },
      expression_attribute_values: {
        ':p' => 5,
        ':f' => 2
      },
      update_expression: 'set pings = :p, failures = :f'
    )
    assert_equal(3, eps.successful_pings(uri))
    eps.del(uri)
  end

  def test_successful_pings_of_absent_endpoint
    WebMock.enable_net_connect!
    eps = Endpoints.new(Dynamo.new.aws, 'yegor256-pings')
    assert_raises(RuntimeError) { eps.successful_pings('http://www.absent-9q8w7e6t.com') }
  end
end
