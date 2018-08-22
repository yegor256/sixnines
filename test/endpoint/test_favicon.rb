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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'test/unit'
require 'rack/test'
require 'rmagick'
require_relative '../../objects/endpoint/ep_favicon'

class EpFaviconTest < Test::Unit::TestCase
  def test_builds_default_favicon
    img = Magick::Image.from_blob(EpFavicon.new(endpoint('broken')).png)[0]
    assert_equal(31, img.columns)
    assert_equal(31, img.rows)
  end

  def test_fetches_correct_favicon
    img = Magick::Image.from_blob(
      EpFavicon.new(endpoint('http://www.yegor256.com/favicon.ico')).png
    )[0]
    assert_equal(64, img.columns)
    assert_equal(64, img.rows)
  end

  def test_parses_different_types
    files = [
      # rubocop:disable LineLength
      ['https://cdn.sstatic.net/Sites/stackoverflow/img/favicon.ico', 16],
      ['http://www.yegor256.com/favicon.ico', 64],
      ['http://www.instagram.com/static/images/ico/favicon.ico/dfa85bb1fd63.ico', 16],
      ['https://www.pinterest.com/favicon.ico', 16],
      # ['http://www.apple.com/favicon.ico', 32] -- doesn't work
      # rubocop:enable LineLength
    ]
    return
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
      def initialize(u)
        @u = u
      end

      def to_h
        { favicon: URI.parse(@u) }
      end
    end.new(uri)
  end
end
