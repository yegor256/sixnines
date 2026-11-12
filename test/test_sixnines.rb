# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'glogin/cookie'
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

  def test_renders_terms_page
    WebMock.enable_net_connect!
    get('/terms')
    assert_predicate(last_response, :ok?, 'Terms page was not rendered, but it should be')
  end

  def test_logout_redirects_home
    WebMock.enable_net_connect!
    get('/logout')
    assert_predicate(last_response, :redirect?, 'Logout did not redirect, but it should')
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

  def test_home_page_does_not_escape_its_markup
    WebMock.enable_net_connect!
    get('/')
    refute_includes(last_response.body, '&lt;', 'Home page markup must not be escaped, but it was')
  end

  def test_history_page_does_not_escape_endpoint_markup
    WebMock.enable_net_connect!
    id = ep("http://www.#{SecureRandom.hex(4)}.com")
    get("/h/#{id}")
    refute_includes(last_response.body, '&lt;', 'History page markup must not be escaped, but it was')
  end

  def test_pings_them
    WebMock.enable_net_connect!
    get('/ping')
    txt = last_response.body
    assert(txt.include?('(none)') || txt.include?('Nothing to ping'))
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
    WebMock.enable_net_connect!
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
    enc = GLogin::Cookie::Open.new({ 'login' => 'tester', 'id' => '99999' }, '').to_s
    set_cookie("glogin=#{enc}")
    get('/a')
    assert_equal(200, last_response.status)
  end

  def test_edit_refuses_endpoint_with_successful_pings
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    login = "tester-#{SecureRandom.hex(2)}"
    old = "http://www.#{SecureRandom.hex(2)}.com"
    Endpoints.new(dynamo, login).add(old)
    dynamo.update_item(
      table_name: 'sn-endpoints',
      key: {
        'login' => login,
        'uri' => old
      },
      expression_attribute_values: {
        ':p' => 2
      },
      update_expression: 'set pings = :p'
    )
    login_as(login)
    error = assert_raises(RuntimeError) do
      post('/a/edit', { old: old, new: "http://www.#{SecureRandom.hex(2)}.com" })
    end
    assert_includes(error.message, 'successful pings', error.message)
    eps = Endpoints.new(dynamo, login).list
    assert_equal(
      [old],
      eps.map { |e| e.to_h[:uri].to_s },
      'The old endpoint must stay untouched'
    )
  end

  def test_edit_allows_endpoint_without_successful_pings
    WebMock.enable_net_connect!
    dynamo = Dynamo.new.aws
    login = "tester-#{SecureRandom.hex(2)}"
    old = "http://www.#{SecureRandom.hex(2)}.com"
    new_uri = "http://www.#{SecureRandom.hex(2)}.com"
    Endpoints.new(dynamo, login).add(old)
    login_as(login)
    post('/a/edit', { old: old, new: new_uri })
    assert_predicate(
      last_response,
      :redirect?,
      'Edit must be allowed when there were no successful pings'
    )
    eps = Endpoints.new(dynamo, login).list
    assert_equal(1, eps.size)
    assert_equal(new_uri, eps[0].to_h[:uri].to_s)
  end

  private

  def login_as(login)
    enc = GLogin::Cookie::Open.new({ 'login' => login, 'id' => '99999' }, '').to_s
    set_cookie("glogin=#{enc}")
  end

  def ep(url)
    dynamo = Dynamo.new.aws
    Endpoints.new(dynamo, 'main').add(url)
  end
end
