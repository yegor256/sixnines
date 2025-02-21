# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'digest/md5'
require_relative 'endpoint'

#
# Endpoints of a user
#
class Endpoints
  def initialize(aws, user)
    @aws = aws
    @user = user
  end

  def add(uri)
    raise "Endpoint URI can't be nil" if uri.nil?
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
      raise "Can't find ID: #{id}" if len > 16
    end
  end
end
