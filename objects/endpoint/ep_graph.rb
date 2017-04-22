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

  def avg
    h = points.map { |p| p[:msec] }
    (h.inject(&:+) || 1) / (h.empty? ? 1 : h.size)
  end

  def avg_full
    "#{avg}ms"
  end

  def to_html
    "<img src='/g/#{@endpoint.to_h[:id]}' alt='graph' class='graph'/>"
  end

  def to_svg
    mean = avg
    h = points
    clean = h.select { |p| p[:msec] < mean * 5 && p[:msec] > mean / 5 }
    xml = if h.empty?
      '<history minx="0" maxx="0" miny="0" maxy="0" avg="#{mean}"/>'
    else
      xorder = clean.sort { |a, b| a[:time] <=> b[:time] }
      yorder = clean.sort { |a, b| a[:msec] <=> b[:msec] }
      "<history now='#{Time.now.to_i}' \
        avg='#{mean}' \
        minx='#{xorder.first[:time].to_i}' maxx='#{xorder.last[:time].to_i}' \
        miny='#{yorder.first[:msec]}' maxy='#{yorder.last[:msec]}'>" +
        h.map do |p|
          "<p time='#{p[:time].to_i}' msec='#{p[:msec]}' code='#{p[:code]}'/>"
        end.join('') + '</history>'
    end
    Nokogiri::XSLT(File.read('assets/xsl/graph.xsl')).transform(
      Nokogiri::XML(xml)
    ).to_s
  end

  private

  def points
    @endpoint.history
  end
end
