# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'endpoints'

#
# Base
#
class Base
  # When not found
  class EndpointNotFound < StandardError
    attr_reader :id

    def initialize(id)
      super
      @id = id
    end
  end

  def initialize(aws)
    @aws = aws
  end

  def ping(count, proxies, &block)
    @aws.query(
      table_name: 'sn-endpoints',
      index_name: 'expires',
      select: 'ALL_ATTRIBUTES',
      limit: 10,
      expression_attribute_values: {
        ':h' => 'yes',
        ':r' => Time.now.to_i
      },
      key_condition_expression: 'active=:h and expires < :r'
    ).items
    .map { |i| Endpoint.new(@aws, i) }
    .map { |e| e.ping(count, proxies, &block) }.join("\n")
  end

  def find(query)
    if query.empty?
      []
    else
      @aws.query(
        table_name: 'sn-endpoints',
        index_name: 'hostnames',
        select: 'ALL_ATTRIBUTES',
        limit: 10,
        expression_attribute_values: {
          ':h' => 'yes',
          ':r' => query
        },
        key_condition_expression: 'active=:h and begins_with(hostname,:r)'
      ).items.map { |i| Endpoint.new(@aws, i) }
    end
  end

  def take(id)
    items = @aws.query(
      table_name: 'sn-endpoints',
      index_name: 'unique',
      select: 'ALL_ATTRIBUTES',
      limit: 1,
      expression_attribute_values: {
        ':h' => id
      },
      key_condition_expression: 'id=:h'
    ).items
    raise EndpointNotFound, id if items.empty?
    Endpoint.new(@aws, items[0])
  end

  def flips
    @aws.query(
      table_name: 'sn-endpoints',
      index_name: 'flips',
      scan_index_forward: false,
      select: 'ALL_ATTRIBUTES',
      limit: 10,
      expression_attribute_values: {
        ':h' => 'yes'
      },
      key_condition_expression: 'active=:h'
    ).items.map { |i| Endpoint.new(@aws, i) }
  end

  def endpoints(user)
    Endpoints.new(@aws, user)
  end
end
