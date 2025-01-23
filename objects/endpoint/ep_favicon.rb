# frozen_string_literal: true

# Copyright (c) 2017-2025 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
