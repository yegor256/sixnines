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
require 'nokogiri'
require_relative '../sixnines'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_renders_version
    get('/version')
    assert(last_response.ok?)
  end

  def test_robots_txt
    get('/robots.txt')
    assert(last_response.ok?)
  end

  def test_it_renders_home_page
    get('/')
    assert(last_response.ok?)
    assert(last_response.body.include?('SixNines'))
    xml = Nokogiri::HTML(last_response.body) do |c|
      c.options = Nokogiri::XML::ParseOptions::STRICT
    end
    assert_equal(1, xml.xpath('/html/head/title').length)
  end

  def test_search_when_no_recent_state_change
    ep('http://www.amazon.com')
    get('/?q=amazon')
    assert(last_response.ok?)
  end

  def test_it_renders_logo
    get('/images/logo.svg')
    assert(last_response.ok?)
  end

  def test_rss_feed
    get('/rss')
    assert_equal(200, last_response.status)
  end

  def test_sitemap
    get('/sitemap.xml')
    assert_equal(200, last_response.status)
  end

  def test_renders_page_not_found
    get('/the-url-that-is-absent')
    assert_equal(404, last_response.status)
  end

  def test_history_endpoint
    id = ep('http://www.ibm.com')
    get("/h/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_history_endpoint_with_user
    id = ep('http://www.vk.com')
    header('Cookie', 'sixnines=jeffrey')
    get("/h/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_history_amp_endpoint
    id = ep('http://www.ibm.com')
    get("/h-amp/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_history_endpoint_not_found
    get('/h/absent')
    assert_equal(404, last_response.status)
  end

  def test_data_endpoint
    id = ep('http://www.stackoverflow.com')
    get("/d/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_data_endpoint_not_found
    get('/d/absent')
    assert_equal(404, last_response.status)
  end

  def test_favicon_endpoint
    id = ep('http://www.yahoo.com')
    get("/f/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_favicon_endpoint_not_found
    get('/f/absent')
    assert_equal(404, last_response.status)
  end

  def test_badge_endpoint
    id = ep('http://www.twitter.com')
    get("/b/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_badge_endpoint_not_found
    get('/b/absent')
    assert_equal(404, last_response.status)
  end

  def test_graph_endpoint
    id = ep('http://www.instagram.com')
    get("/g/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_graph_endpoint_not_found
    get('/g/absent')
    assert_equal(404, last_response.status)
  end

  def test_user_account
    header('Cookie', 'sixnines=jeff')
    get('/a')
    assert_equal(200, last_response.status)
  end

  private

  def ep(url)
    dynamo = Dynamo.new.aws
    Endpoints.new(dynamo, 'main').add(url)
  end
end
