# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'test/unit'
require 'rack/test'
require 'rmagick'
require_relative '../../objects/endpoint/ep_badge'

class BadgeTest < Test::Unit::TestCase
  def test_renders_svg
    endpoint = Class.new do
      def to_h
        {
          id: '1234567',
          pings: 100,
          failures: 10,
          up: true
        }
      end
    end.new
    target = File.join(Dir.pwd, 'target')
    FileUtils.mkdir_p(target)
    svg = EpBadge.new(endpoint).to_svg
    File.write(File.join(target, 'badge.svg'), svg)
    assert(svg.include?('<svg'))
  end

  def test_renders_png
    endpoint = Class.new do
      def to_h
        {
          id: '1234567',
          pings: 10_000,
          failures: 20,
          up: true
        }
      end
    end.new
    target = File.join(Dir.pwd, 'target')
    FileUtils.mkdir_p(target)
    png = EpBadge.new(endpoint).to_png
    File.write(File.join(target, 'badge.png'), png)
    img = Magick::Image.from_blob(png)[0]
    assert_equal(424, img.columns)
  end
end
