# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'test/unit'
require 'rack/test'
require_relative '../objects/counted_resource'
require_relative '../objects/resource'
require_relative '../objects/dynamo'
require_relative '../objects/total_pings'

class CountedResourceTest < Test::Unit::TestCase
  START = 5
  PINGS = 3

  def test_increments_on_ping
    stub = stub_request(:any, 'www.ebay.com')
    count = TotalPings.new(START)
    resource = CountedResource.new(
      count,
      Resource.new(URI.parse('http://www.ebay.com'))
    )
    PINGS.times do
      resource.take
    end
    assert_equal(START + PINGS, count.count)
    remove_request_stub(stub)
  end
end
