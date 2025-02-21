# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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

  def to_html(amp: false)
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
