# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'nokogiri'
require_relative '../sixnines'
require_relative 'test__helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_renders_version
    WebMock.enable_net_connect!
    get('/version')
    assert_predicate(last_response, :ok?)
  end

  def test_robots_txt
    WebMock.enable_net_connect!
    get('/robots.txt')
    assert_predicate(last_response, :ok?)
  end

  def test_css
    WebMock.enable_net_connect!
    get('/css/main.css')
    assert_predicate(last_response, :ok?)
    refute_empty(last_response.body)
    assert_includes(last_response.body, 'body {', last_response.body)
  end

  def test_it_renders_home_page
    WebMock.enable_net_connect!
    get('/')
    assert_predicate(last_response, :ok?)
    html = last_response.body
    assert_includes(html, 'SixNines')
  end

  def test_it_renders_valid_html
    skip('It does not work for some reason, even though HTML is valid')
    get('/')
    assert_predicate(last_response, :ok?)
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
    WebMock.enable_net_connect!
    ep('http://www.amazon.com')
    get('/?q=amazon')
    assert_predicate(last_response, :ok?)
  end

  def test_it_renders_logo
    WebMock.enable_net_connect!
    get('/images/logo.svg')
    assert_predicate(last_response, :ok?)
  end

  def test_rss_feed
    WebMock.enable_net_connect!
    get('/rss')
    assert_equal(200, last_response.status)
  end

  def test_sitemap
    WebMock.enable_net_connect!
    get('/sitemap.xml')
    assert_equal(200, last_response.status)
  end

  def test_renders_page_not_found
    WebMock.enable_net_connect!
    get('/the-url-that-is-absent')
    assert_equal(404, last_response.status)
  end

  def test_history_endpoint
    WebMock.enable_net_connect!
    id = ep('http://www.ibm.com')
    get("/h/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_history_endpoint_with_user
    WebMock.enable_net_connect!
    id = ep('http://www.vk.com')
    header('Cookie', 'glogin=jeffrey|')
    get("/h/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_history_amp_endpoint
    WebMock.enable_net_connect!
    id = ep('http://www.ibm.com')
    get("/h-amp/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_history_endpoint_not_found
    WebMock.enable_net_connect!
    get('/h/absent')
    assert_equal(404, last_response.status)
  end

  def test_data_endpoint
    WebMock.enable_net_connect!
    id = ep('http://www.stackoverflow.com')
    get("/d/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_data_endpoint_not_found
    WebMock.enable_net_connect!
    get('/d/absent')
    assert_equal(404, last_response.status)
  end

  def test_favicon_endpoint
    WebMock.enable_net_connect!
    id = ep('http://www.yahoo.com')
    get("/f/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_favicon_endpoint_not_found
    WebMock.enable_net_connect!
    get('/f/absent')
    assert_equal(404, last_response.status)
  end

  def test_badge_endpoint
    WebMock.enable_net_connect!
    id = ep('http://www.twitter.com')
    get("/b/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_badge_endpoint_not_found
    get('/b/absent')
    assert_equal(404, last_response.status)
  end

  def test_graph_endpoint
    WebMock.enable_net_connect!
    id = ep('http://www.instagram.com')
    get("/g/#{id}")
    assert_equal(200, last_response.status)
  end

  def test_graph_endpoint_not_found
    WebMock.enable_net_connect!
    get('/g/absent')
    assert_equal(404, last_response.status)
  end

  def test_user_account
    WebMock.enable_net_connect!
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
