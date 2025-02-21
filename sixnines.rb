# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'haml'
require 'haml/template/options'
require 'sinatra'
require 'sinatra/cookies'
require 'sass'
require 'futex'
require 'uri'
require 'yaml'
require 'json'
require 'aws-sdk-dynamodb'
require 'stripe'
require 'twitter'
require 'raven'
require 'net/http'
require 'glogin'
require_relative 'version'
require_relative 'objects/helpers'
require_relative 'objects/exec'
require_relative 'objects/base'
require_relative 'objects/dynamo'
require_relative 'objects/endpoint/ep_favicon'
require_relative 'objects/endpoint/ep_data'

if ENV['RACK_ENV'] != 'test'
  require 'rack/ssl'
  use Rack::SSL
end

configure do
  Haml::Options.defaults[:format] = :xhtml
  config = if ENV['RACK_ENV'] == 'test'
    {
      'cookie_secret' => '',
      'github' => {
        'client_id' => 'test',
        'client_secret' => 'test'
      },
      'twitter' => {
        'consumer_key' => 'test',
        'consumer_secret' => 'test',
        'access_token' => 'test',
        'access_token_secret' => 'test'
      },
      'sentry' => '',
      'stripe' => {
        'live' => {
          'public_key' => 'test'
        }
      },
      'proxies' => [''],
      'coupons' => ['test']
    }
  else
    YAML.safe_load(File.open(File.join(Dir.pwd, 'config.yml')))
  end
  Raven.configure do |c|
    c.dsn = config['sentry']
  end
  set :config, config
  set :glogin, GLogin::Auth.new(
    config['github']['client_id'],
    config['github']['client_secret'],
    'https://www.sixnines.io/oauth'
  )
  set :base, Base.new(Dynamo.new(config).aws)
  set :proxies, config['proxies']
  set :twitter, (Twitter::REST::Client.new do |c|
    c.consumer_key = config['twitter']['consumer_key']
    c.consumer_secret = config['twitter']['consumer_secret']
    c.access_token = config['twitter']['access_token']
    c.access_token_secret = config['twitter']['access_token_secret']
  end)
  set :pings, TotalPings.new(0)
end

before '/*' do
  @locals = {
    ver: VERSION,
    login_link: settings.glogin.login_uri
  }
  cookies[:glogin] = params[:cookie] if params[:cookie]
  if cookies[:glogin]
    begin
      @locals[:user] = GLogin::Cookie::Closed.new(
        cookies[:glogin],
        settings.config['cookie_secret']
      ).to_user
    rescue GLogin::Codec::DecodingError => _e
      @locals.delete(:user)
    end
  end
end

before '/a*' do
  redirect to('/') unless @locals[:user]
end

get '/oauth' do
  code = params[:code]
  return 'The code is missing' if code.nil?
  cookies[:glogin] = GLogin::Cookie::Open.new(
    settings.glogin.user(code),
    settings.config['cookie_secret']
  ).to_s
  redirect to('/')
end

get '/logout' do
  cookies.delete(:glogin)
  redirect to('/')
end

get '/terms' do
  haml :terms, layout: :layout, locals: @locals.merge(
    title: 'Terms of use',
    description: 'Terms of use'
  )
end

get '/' do
  haml :index, layout: :layout, locals: @locals.merge(
    title: 'SixNines',
    description: 'Website Availability Monitor',
    query: params[:q],
    found: params[:q] ? settings.base.find(params[:q]) : [],
    flips: settings.base.flips,
    ping_count: settings.pings.count
  )
end

get '/rss' do
  require 'rss'
  content_type 'application/rss+xml'
  RSS::Maker.make('atom') do |m|
    m.channel.author = 'SixNines.io'
    m.channel.updated = Time.now.to_s
    m.channel.about = 'https://sixnines.io/rss'
    m.channel.title = 'SixNines recent flips'
    settings.base.flips.each do |e|
      m.items.new_item do |i|
        i.link = "https://www.sixnines.io/h/#{e.to_h[:id]}"
        i.title = "#{e.to_h[:hostname]} flipped"
        i.updated = Time.now.to_s
      end
    end
  end.to_s
end

get '/sitemap.xml' do
  require 'xml-sitemap'
  content_type 'application/xml'
  XmlSitemap::Map.new('sixnines.io') do |m|
    settings.base.flips.each do |e|
      m.add(
        "/h/#{e.to_h[:id]}",
        updated: e.to_h[:flipped],
        period: :never
      )
    end
  end.render
end

# Badge of the endpoint
get '/b/:id' do
  response.headers['Cache-Control'] = 'no-cache, private'
  badge = EpBadge.new(settings.base.take(params[:id]))
  style = params[:style] == 'flat' ? 'flat' : 'round'
  if params[:format] && params[:format] == 'png'
    content_type 'image/png'
    badge.to_png(style)
  else
    content_type 'image/svg+xml'
    badge.to_svg(style)
  end
rescue Base::EndpointNotFound
  404
end

# History page of the endpoint
get '/h/:id' do
  ep = settings.base.take(params[:id])
  haml :history, layout: :layout, locals: @locals.merge(
    title: "sn:#{ep.to_h[:hostname]}",
    description: "#{ep.to_h[:hostname]}: availability report",
    amphtml: "/h-amp/#{params[:id]}",
    e: Endpoint::Cached.new(ep)
  )
rescue Base::EndpointNotFound
  404
end

# History page of the endpoint (AMP)
get '/h-amp/:id' do
  ep = settings.base.take(params[:id])
  haml :history_amp, layout: :amp, locals: @locals.merge(
    title: ep.to_h[:hostname],
    description: ep.to_h[:hostname],
    canonical: "/h/#{params[:id]}",
    e: Endpoint::Cached.new(ep)
  )
rescue Base::EndpointNotFound
  404
end

# SVG graph of the endpoint
get '/g/:id' do
  response.headers['Cache-Control'] = 'no-cache, private'
  content_type 'image/svg+xml'
  EpGraph.new(Endpoint::Cached.new(settings.base.take(params[:id]))).to_svg
rescue Base::EndpointNotFound
  404
end

# Favicon of the endpoint
get '/f/:id' do
  response.headers['Cache-Control'] = "max-age=#{5 * 60 * 60}"
  content_type 'image/png'
  EpFavicon.new(settings.base.take(params[:id])).png
rescue Base::EndpointNotFound
  404
end

# Data of the endpoint
get '/d/:id' do
  content_type 'application/json'
  EpData.new(settings.base.take(params[:id])).to_json
rescue Base::EndpointNotFound
  404
end

# Flush the endpoint
get '/flush/:id' do
  raise 'You are not allowed to do this' \
    if @locals[:user].nil? || @locals[:user][:id] != 'yegor256'
  begin
    ep = settings.base.take(params[:id])
    ep.flush
    redirect(to("/h/#{params[:id]}"))
  rescue Base::EndpointNotFound
    404
  end
end

get '/ping' do
  content_type 'text/plain'
  txt = Futex.new('/tmp/sixnines.lock', timeout: 1).open do
    settings.base.ping(settings.pings, settings.proxies) do |up, ep|
      next if ENV['RACK_ENV'] == 'test'
      href = "https://www.sixnines.io#{EpBadge.new(ep).to_href}"
      event = 'is down'
      if up
        event = 'is up'
        if ep.to_h[:flipped]
          event = "went back up after \
#{time_ago_in_words(ep.to_h[:flipped])} \
of downtime"
        end
      end
      begin
        settings.twitter.update(
          "#{ep.to_h[:hostname]} #{event}! \
Availability: #{EpAvailability.new(ep).short} \
(#{EpAvailability.new(ep).full}). #{href}"
        )
      rescue Twitter::Error::Unauthorized
        puts 'Can\'t tweet, account is locked'
      rescue Twitter::Error::ServiceUnavailable
        puts 'Can\'t tweet, service unavailable'
      end
    end
  end
  return 'Nothing to ping' if txt.empty?
  Process.detach(
    fork do
      sleep(10)
      Net::HTTP.get_response(URI.parse('https://www.sixnines.io/ping?fork'))
    end
  )
rescue Futex::CantLock
  'Locked, try again a bit later'
end

get '/robots.txt' do
  'sitemap: https://www.sixnines.io/sitemap.xml'
end

get '/version' do
  VERSION
end

get '/a' do
  haml :account, layout: :layout, locals: @locals.merge(
    title: "@#{@locals[:user][:id]}",
    description: "Account of @#{@locals[:user][:id]}",
    endpoints: settings.base.endpoints(@locals[:user][:id]).list,
    stripe_key: settings.config['stripe']['live']['public_key']
  )
end

post '/a/add' do
  if params[:coupon].empty?
    Stripe.api_key = settings.config['stripe']['live']['secret_key']
    customer = Stripe::Customer.create(
      email: params[:stripeEmail],
      source: params[:stripeToken]
    )
    Stripe::Charge.create(
      amount: 495,
      description: params[:endpoint],
      currency: 'usd',
      customer: customer.id
    )
  else
    raise "Invalid coupon \"#{params[:coupon]}\"" unless settings.config['coupons'].include?(params[:coupon])
  end
  settings.base.endpoints(@locals[:user][:id]).add(params[:endpoint])
  redirect to('/a')
end

# @todo #93:30min We should check that there were no successful pings before
#  changing the endpoint to ensure no one uses this feature to register new
#  sites without charge.
post '/a/edit' do
  settings.base.endpoints(@locals[:user][:id]).del(params[:old])
  settings.base.endpoints(@locals[:user][:id]).add(params[:new])
  redirect to('/a')
end

get '/a/del' do
  settings.base.endpoints(@locals[:user][:id]).del(params[:endpoint])
  redirect to('/a')
end

get '/ping_count' do
  content_type 'application/json'
  { ping_count: settings.pings.count }.to_json
end

get '/css/*.css' do
  name = params[:splat].first
  file = File.join('assets/sass', "#{name}.sass")
  error(404, "File not found: #{file}") unless File.exist?(file)
  content_type 'text/css', charset: 'utf-8'
  Sass::Engine.new(File.read(file)).render
end

not_found do
  status 404
  haml :not_found, layout: :layout, locals: @locals.merge(
    title: 'Page not found',
    description: 'Page not found'
  )
end

error do
  status 503
  content_type 'text/html'
  e = env['sinatra.error']
  Raven.capture_exception(e)
  haml(
    :error,
    layout: :layout,
    locals: @locals.merge(
      title: 'Error',
      description: 'Internal server error',
      error: "#{e.message}\n\t#{e.backtrace.join("\n\t")}"
    )
  )
end
