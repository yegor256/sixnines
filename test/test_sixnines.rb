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
  end

  def test_it_renders_logo
    get('/images/logo.svg')
    assert(last_response.ok?)
  end

  def test_rss_feed
    get('/rss')
    assert(last_response.status == 200)
  end

  def test_renders_page_not_found
    get('/the-url-that-is-absent')
    assert(last_response.status == 404)
  end

  def test_history_endpoint_not_found
    get('/h/absent')
    assert(last_response.status == 404)
  end

  def test_favicon_endpoint_not_found
    get('/f/absent')
    assert(last_response.status == 404)
  end

  def test_badge_endpoint_not_found
    get('/b/absent')
    assert(last_response.status == 404)
  end

  def test_graph_endpoint_not_found
    get('/g/absent')
    assert(last_response.status == 404)
  end
end
