# frozen_string_literal: true

# Copyright (c) 2017-2023 Yegor Bugayenko
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
