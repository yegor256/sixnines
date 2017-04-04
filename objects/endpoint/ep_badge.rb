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
require_relative 'ep_availability'

#
# Badge of endpoint
#
class EpBadge
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def to_src
    "/b/#{@endpoint.to_h[:id]}"
  end

  def to_href
    "/h/#{@endpoint.to_h[:id]}"
  end

  def to_html
    "<a href='#{to_href}'><img src='#{to_src}'/></a>"
  end

  def to_svg
    Nokogiri::XSLT(File.read('assets/xsl/badge.xsl')).transform(
      Nokogiri::XML(
        "<endpoint>\
          <availability>#{EpAvailability.new(@endpoint).short}</availability>\
          <state>#{EpState.new(@endpoint).to_b}</state>\
        </endpoint>"
      )
    ).to_s
  end
end
