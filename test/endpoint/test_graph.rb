# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'test/unit'
require 'rack/test'
require_relative '../../objects/endpoint/ep_graph'

class GraphTest < Test::Unit::TestCase
  def test_renders_svg
    endpoint = Class.new do
      def history
        [
          { time: Time.now - 16_000, msec: 120, code: 200 },
          { time: Time.now - 12_000, msec: 4000, code: 200 },
          { time: Time.now - 4800, msec: 210, code: 200 },
          { time: Time.now - 2400, msec: 110, code: 200 },
          { time: Time.now - 1800, msec: 210, code: 503 },
          { time: Time.now - 320, msec: 107, code: 200 },
          { time: Time.now - 220, msec: 210, code: 200 },
          { time: Time.now - 60, msec: 450, code: 503 },
          { time: Time.now, msec: 75, code: 200 }
        ]
      end
    end.new
    target = File.join(Dir.pwd, 'target')
    FileUtils.mkdir_p(target)
    svg = EpGraph.new(endpoint).to_svg
    File.write(File.join(target, 'graph.svg'), svg)
    assert(svg.include?('<svg'))
  end

  def test_calculates_avg
    endpoint = Class.new do
      def history
        [
          { time: Time.now - 180, msec: 1298, code: 200 },
          { time: Time.now - 120, msec: 217, code: 200 },
          { time: Time.now - 60, msec: 451, code: 503 },
          { time: Time.now, msec: 75, code: 200 }
        ]
      end
    end.new
    assert_equal(510, EpGraph.new(endpoint).avg)
  end
end
