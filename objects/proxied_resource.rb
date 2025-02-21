# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'uri'
require 'timeout'
require 'net/http'
require 'openssl'
require_relative 'resource'

#
# Proxied single web resource.
#
class ProxiedResource
  def initialize(resource, proxies = [''])
    @resource = resource
    @proxies = proxies
  end

  def take
    a = [500, '', 'There are no proxies']
    @proxies.each do |p|
      host, port = p.split(':')
      begin
        a = @resource.take(host, port)
      rescue Net::HTTPClientException => e
        code = e.message.split[0].to_i
        raise e unless code == 407
        a = Response.new(200, '', e.message).receive
      end
      break if a[0] != 500 || !a[1].empty?
    end
    a = Response.new(200, '', '407 proxy issue').receive if a[0] == 407
    a
  end
end
