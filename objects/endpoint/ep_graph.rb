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

#
# Graph of endpoint
#
class EpGraph
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def to_html
    "<img src='http://www.sixnines.io/g/#{@endpoint.to_h[:id]}'/>"
  end

  def to_svg
    h = @endpoint.history
    xorder = h.sort { |a, b| a[:time] <=> b[:time] }
    yorder = h.sort { |a, b| a[:msec] <=> b[:msec] }
    Nokogiri::XSLT(File.read('assets/xsl/graph.xsl')).transform(
      Nokogiri::XML(
        "<history \
minx='#{xorder.first[:time]}' maxx='#{xorder.last[:time]}' \
miny='#{yorder.first[:msec]}' maxy='#{xorder.last[:msec]}'>" +
        @endpoint.history.map do |p|
          "<p time='#{p[:time].to_i}' msec='#{p[:msec]}' code='#{p[:code]}'/>"
        end.join('') + '</history>'
      )
    ).to_s
  end
end
