# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'uri'
require 'timeout'
require 'net/http'
require 'openssl'
require_relative 'resource'
require_relative 'proxied_resource'
require_relative 'counted_resource'
require_relative 'total_pings'
require_relative 'endpoint/ep_uri'
require_relative 'endpoint/ep_state'
require_relative 'endpoint/ep_availability'
require_relative 'endpoint/ep_badge'
require_relative 'endpoint/ep_graph'

#
# Single endpoint
#
class Endpoint
  # Cached endpoint
  class Cached
    def initialize(point)
      @point = point
      @history = nil
    end

    def to_h
      @point.to_h
    end

    def history
      @history ||= @point.history
    end

    def ping
      @point.ping
    end

    def flush
      @point.flush
    end
  end

  def initialize(aws, item)
    @aws = aws
    @item = item
  end

  def to_h
    h = {
      uri: URI.parse(@item['uri']),
      favicon: @item['favicon'] ? URI.parse(@item['favicon']) : nil,
      login: @item['login'],
      id: @item['id'],
      hostname: @item['hostname'],
      failures: @item['failures'].to_i,
      pings: @item['pings'].to_i,
      up: @item['state'] == 'up',
      created: Time.at(@item['created']),
      log: @item['log']
    }
    h[:updated] = Time.at(@item['updated']) if @item['updated']
    h[:flipped] = Time.at(@item['flipped']) if @item['flipped']
    h[:expires] = Time.at(@item['expires']) if @item['expires']
    h
  end

  def history
    @aws.query(
      table_name: 'sn-pings',
      select: 'SPECIFIC_ATTRIBUTES',
      projection_expression: '#time, msec, code',
      limit: 1000,
      scan_index_forward: false,
      expression_attribute_names: {
        '#time' => 'time'
      },
      expression_attribute_values: {
        ':u' => @item['uri'],
        ':t' => (Time.now - (1000 * 60)).to_i
      },
      key_condition_expression: 'uri = :u and #time > :t'
    ).items.map do |i|
      {
        time: Time.at(i['time']),
        msec: i['msec'].to_i,
        code: i['code'].to_i
      }
    end
  end

  def ping(count, proxies = [''])
    start = Time.now
    h = to_h
    code, body, log = ProxiedResource.new(
      CountedResource.new(
        count,
        Resource.new(h[:uri])
      ),
      proxies
    ).take
    @aws.put_item(
      table_name: 'sn-pings',
      item: {
        uri: h[:uri].to_s,
        code: code,
        time: Time.now.to_i,
        msec: ((Time.now - start) * 1000).to_i,
        local: 'unknown',
        remote: 'unknown',
        delete_on: (Time.now + (24 * 60 * 60)).to_i
      }
    )
    up = code >= 200 && code < 300
    update = [
      'updated = :t',
      'expires = :e',
      'favicon = :f',
      'pings = pings + :o',
      '#state = :s'
    ]
    ean = {
      '#state' => 'state'
    }
    eav = {
      ':s' => up ? 'up' : 'down',
      ':o' => 1,
      ':t' => Time.now.to_i,
      ':e' => (Time.now + 60).to_i, # ping again in 60 seconds
      ':f' => favicon(body).to_s
    }
    update << 'failures = failures + :o' unless up
    update << 'flipped = :t' unless up == h[:up]
    unless up
      update << '#log = :g'
      ean['#log'] = 'log'
      eav[':g'] = "#{Time.now}\n\n#{log}"
    end
    @aws.update_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => h[:login],
        'uri' => h[:uri].to_s
      },
      expression_attribute_names: ean,
      expression_attribute_values: eav,
      update_expression: "set #{update.join(', ')}"
    )
    yield(up, self) if block_given? && up != h[:up]
    "#{h[:uri]}: #{code}"
  end

  def flush
    h = to_h
    @aws.update_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => h[:login],
        'uri' => h[:uri].to_s
      },
      expression_attribute_names: {
        '#log' => 'log',
        '#failures' => 'failures'
      },
      expression_attribute_values: {
        ':f' => 0
      },
      update_expression: 'REMOVE #log SET #failures=:f'
    )
  end

  private

  def favicon(body)
    xml = Nokogiri::HTML(body)
    links = xml.xpath('/html/head/link[@rel="shortcut icon"]/@href')
    uri = to_h[:uri]
    raise "Favicon URI can't be nil in the endpoint" if uri.nil?
    if links.empty?
      URI.parse("http://#{uri.host}/favicon.ico")
    else
      uri = URI.parse(links[0])
      uri = URI.parse("http://#{uri.host}#{uri}") unless uri.absolute?
      uri
    end
  rescue StandardError => _e
    URI.parse('localhost')
  end
end
