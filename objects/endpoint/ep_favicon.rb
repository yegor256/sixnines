# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require 'rmagick'
require 'net/http'
require 'tmpdir'
require 'openssl'

#
# Favicon of a endpoint
#
class EpFavicon
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def png
    Dir.mktmpdir do |dir|
      uri = @endpoint.to_h[:favicon]
      raise 'Favicon URI is nil' if uri.nil?
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      req = Net::HTTP::Get.new(uri.request_uri)
      req['User-Agent'] = 'SixNines.io (not Firefox, Chrome, or Safari)'
      res = http.request(req)
      type = case res['Content-Type']
        when 'image/png'
          'png'
        when 'image/gif'
          'gif'
        else
          'ico'
        end
      f = File.join(dir, "image.#{type}")
      File.write(f, res.body)
      img = Magick::Image.read(f)[0]
      img.format = 'PNG'
      img.to_blob
    end
  rescue StandardError => _e
    File.read(File.join(Dir.pwd, 'assets/images/default-favicon.png'))
  end
end
