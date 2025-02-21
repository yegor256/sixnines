# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative 'response'

#
# HTTP response
#
class HTTPResponse
  def initialize(http, request)
    @http = http
    @request = request
  end

  def receive
    response = @http.request(@request)
    Response.new(
      response.code,
      response.body,
      to_text(@request, response)
    ).receive
  end

  private

  def to_text(req, res)
    "#{req.method} #{req.path} HTTP/1.1\n\
#{headers(req)}\n#{body(req.body)}\n\n\
HTTP/#{res.http_version} #{res.code} #{res.message}\n\
#{headers(res)}\n#{body(res.body)}"
  end

  def headers(headers)
    headers.to_hash.map { |k, v| v.map { |h| "#{k}: #{h}" } }.join("\n")
  end

  def body(body)
    body.nil? ? '' : body.strip.gsub(/^(.{200,}?).*$/m, '\1...')
  end
end
