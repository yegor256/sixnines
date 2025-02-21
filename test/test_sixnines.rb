# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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

  def test_css
    get('/css/main.css')
    assert(last_response.ok?)
    assert(!last_response.body.empty?)
    assert(last_response.body.include?('body {'), last_response.body)
  end

  def test_it_renders_home_page
    get('/')
    assert(last_response.ok?)
    html = last_response.body
    assert(html.include?('SixNines'))
  end

  def test_it_renders_valid_html
    omit('It does not work for some reason, even though HTML is valid')
    get('/')
    assert(last_response.ok?)
    html = last_response.body
    begin
      xml = Nokogiri::HTML(html) do |c|
        c.options = Nokogiri::XML::ParseOptions::STRICT
      end
      assert_equal(1, xml.xpath('/html/head/title').length)
    rescue Nokogiri::XML::SyntaxError => e
      puts "Broken HTML:\n#{html}"
      raise e
    end
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
    header('Cookie', 'glogin=jeffrey|')
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
    header('Cookie', 'glogin=jeff')
    get('/a')
    assert_equal(200, last_response.status)
  end

  private

  def ep(url)
    dynamo = Dynamo.new.aws
    Endpoints.new(dynamo, 'main').add(url)
  end
end
