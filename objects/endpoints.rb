# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'digest/md5'
require_relative 'endpoint'

#
# Endpoints of a user
#
class Endpoints
  def initialize(aws, user)
    @aws = aws
    raise 'User is nil' if user.nil?
    raise 'User login must be a string' unless user.is_a?(String)
    @user = user
  end

  def add(uri)
    raise 'Endpoint URI cannot be nil' if uri.nil?
    id = unique_id(uri)
    @aws.put_item(
      table_name: 'sn-endpoints',
      item: {
        'login' => @user,
        'uri' => uri,
        'id' => id,
        'active' => 'yes',
        'created' => Time.now.to_i,
        'hostname' => URI.parse(uri).host.gsub(/^www\./, ''),
        'pings' => 0,
        'failures' => 0,
        'succeeds' => 0,
        'expires' => 0
      }
    )
    id
  end

  def del(uri)
    @aws.delete_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => @user,
        'uri' => uri
      }
    )
  end

  # Deletes the endpoint only if it has never pinged successfully.
  # DynamoDB checks the condition atomically at the moment of deletion,
  # so a first success recorded by a background ping a moment earlier
  # still refuses the deletion. An absent endpoint is refused too,
  # since allowing the edit would still enable free registration.
  def del_fresh(uri)
    raise 'Endpoint URI cannot be nil' if uri.nil?
    @aws.delete_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => @user,
        'uri' => uri
      },
      condition_expression: 'attribute_exists(login) AND (attribute_not_exists(#succeeds) OR #succeeds = :zero)',
      expression_attribute_names: {
        '#succeeds' => 'succeeds'
      },
      expression_attribute_values: {
        ':zero' => 0
      }
    )
  rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
    pings = successful_pings(uri)
    raise "You cannot change \"#{uri}\", it already has #{pings} successful pings"
  end

  # Total number of successful pings of the given endpoint, tracked
  # in the dedicated "succeeds" counter, which is not reset by flush
  def successful_pings(uri)
    raise 'Endpoint URI cannot be nil' if uri.nil?
    item = @aws.get_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => @user,
        'uri' => uri
      }
    ).item
    raise "Endpoint \"#{uri}\" is absent" if item.nil? || item.empty?
    item['succeeds'].to_i
  end

  def list
    @aws.query(
      table_name: 'sn-endpoints',
      select: 'ALL_ATTRIBUTES',
      limit: 50,
      expression_attribute_values: {
        ':v' => @user
      },
      key_condition_expression: 'login = :v'
    ).items.map { |i| Endpoint.new(@aws, i) }
  end

  private

  def unique_id(uri)
    len = 4
    loop do
      id = Digest::MD5.hexdigest(uri)[0, len]
      items = @aws.query(
        table_name: 'sn-endpoints',
        index_name: 'unique',
        limit: 1,
        expression_attribute_values: { ':h' => id },
        key_condition_expression: 'id=:h'
      ).items
      return id if items.empty?
      len += 1
      raise "Cannot find ID: #{id}" if len > 16
    end
  end
end
