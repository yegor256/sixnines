# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'rmagick'
require_relative '../../objects/endpoint/ep_favicon'
require_relative '../test__helper'

class EpFaviconTest < Minitest::Test
  def test_builds_default_favicon
    WebMock.enable_net_connect!
    img = Magick::Image.from_blob(EpFavicon.new(endpoint('broken')).png)[0]
    assert_equal(31, img.columns)
    assert_equal(31, img.rows)
  end

  def test_fetches_correct_favicon
    WebMock.enable_net_connect!
    img = Magick::Image.from_blob(
      EpFavicon.new(endpoint('https://www.yegor256.com/favicon.ico')).png
    )[0]
    assert_equal(64, img.columns)
    assert_equal(64, img.rows)
  end

  def test_parses_different_types
    WebMock.enable_net_connect!
    files = [
      ['https://cdn.sstatic.net/Sites/stackoverflow/img/favicon.ico', 16],
      ['https://www.yegor256.com/favicon.ico', 64],
      ['https://www.instagram.com/static/images/ico/favicon.ico/dfa85bb1fd63.ico', 16],
      ['https://www.pinterest.com/favicon.ico', 16]
      # ['http://www.apple.com/favicon.ico', 32] -- doesn't work
    ]
    files.each do |f, w|
      img = Magick::Image.from_blob(
        EpFavicon.new(endpoint(f)).png
      )[0]
      assert_equal(w, img.columns, f)
    end
  end

  private

  def endpoint(uri)
    Class.new do
      def initialize(url)
        super()
        @url = url
      end

      def to_h
        { favicon: URI.parse(@url) }
      end
    end.new(uri)
  end
end
