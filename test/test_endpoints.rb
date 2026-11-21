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

  def test_counts_recorded_successes
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
        ':p' => 3,
        ':f' => 0,
        ':s' => 3
      },
      update_expression: 'set pings = :p, failures = :f, succeeds = :s'
    )
    assert_equal(3, eps.successful_pings(uri))
    eps.del(uri)
  end

  def test_flush_of_never_succeeded_endpoint_does_not_invent_successes
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    eps = Endpoints.new(dynamo, 'yegor256-pings')
    uri = 'http://www.sixnines.io'
    eps.add(uri)
    # This is the state of a never-succeeded endpoint after one failed
    # ping (pings stays, failures reset): `pings - failures` would lie
    dynamo.update_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => 'yegor256-pings',
        'uri' => uri
      },
      expression_attribute_values: {
        ':p' => 1,
        ':f' => 0
      },
      update_expression: 'set pings = :p, failures = :f'
    )
    assert_equal(
      0,
      eps.successful_pings(uri),
      'A failed ping followed by flush must not count as a success'
    )
    eps.del(uri)
  end

  def test_successful_pings_of_absent_endpoint
    WebMock.enable_net_connect!
    eps = Endpoints.new(Dynamo.new.aws, 'yegor256-pings')
    assert_raises(RuntimeError) { eps.successful_pings('http://www.absent-9q8w7e6t.com') }
  end

  def test_deletes_fresh_endpoint
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    eps = Endpoints.new(dynamo, 'yegor256-pings')
    uri = 'http://www.sixnines.io'
    eps.add(uri)
    eps.del_fresh(uri)
    assert_equal([], eps.list.map { |e| e.to_h[:uri].to_s })
  end

  def test_refuses_to_delete_endpoint_with_successes
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
        ':s' => 2
      },
      update_expression: 'set succeeds = :s'
    )
    error = assert_raises(RuntimeError) { eps.del_fresh(uri) }
    assert_includes(error.message, 'successful pings', error.message)
    assert_equal(
      [uri],
      eps.list.map { |e| e.to_h[:uri].to_s },
      'The endpoint with successful pings must stay untouched'
    )
    eps.del(uri)
  end

  def test_refuses_to_delete_absent_endpoint
    WebMock.enable_net_connect!
    eps = Endpoints.new(Dynamo.new.aws, 'yegor256-pings')
    error = assert_raises(RuntimeError) { eps.del_fresh('http://www.absent-9q8w7e6t.com') }
    assert_includes(error.message, 'absent', error.message)
  end
end
