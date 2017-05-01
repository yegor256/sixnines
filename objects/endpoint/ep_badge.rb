# encoding: utf-8
#
# Copyright (c) 2017 Yegor Bugayenko
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
require 'shellwords'
require_relative '../exec'
require_relative 'ep_availability'
require_relative 'ep_state'

#
# Badge of endpoint
#
class EpBadge
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def to_src
    "/b/#{@endpoint.to_h[:id]}?style=flat"
  end

  def to_href
    "/h/#{@endpoint.to_h[:id]}"
  end

  def to_html(amp = false)
    "<a href='#{to_href}'><#{amp ? 'amp-' : ''}img src='#{to_src}' \
alt='#{@endpoint.to_h[:hostname]} availability badge' \
width='106' height='20'/></a>"
  end

  def to_svg(style = 'round')
    Nokogiri::XSLT(File.read('assets/xsl/badge.xsl')).transform(
      Nokogiri::XML(
        "<endpoint>\
          <availability>#{EpAvailability.new(@endpoint)}</availability>\
          <text>#{EpAvailability.new(@endpoint).short}</text>\
          <state>#{EpState.new(@endpoint).to_b}</state>\
        </endpoint>"
      ),
      ['style', "'#{style}'"]
    ).to_s
  end

  def to_png(style = 'round')
    Tempfile.open(['img', '.svg']) do |svg|
      Tempfile.open(['img', '.png']) do |png|
        svg.write(to_svg(style))
        svg.flush
        Exec.new(
          [
            'convert',
            '-density 424',
            '-resize 424x',
            '-background none',
            Shellwords.escape(svg.path),
            Shellwords.escape(png.path)
          ].join(' ')
        ).run
        png.read
      end
    end
  end
end
