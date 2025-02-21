# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
      "<history minx='0' maxx='0' miny='0' maxy='0' avg='#{mean}'/>"
    else
      xorder = clean.sort { |a, b| a[:time] <=> b[:time] }
      yorder = clean.sort { |a, b| a[:msec] <=> b[:msec] }
      [
        "<history now='#{Time.now.to_i}' \
          avg='#{mean}' \
          minx='#{xorder.first[:time].to_i}' maxx='#{xorder.last[:time].to_i}' \
          miny='#{yorder.first[:msec]}' maxy='#{yorder.last[:msec]}'>",
        h.map do |p|
          "<p time='#{p[:time].to_i}' msec='#{p[:msec]}' code='#{p[:code]}'/>"
        end.join,
        '</history>'
      ].join
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
