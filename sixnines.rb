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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'haml'
require 'haml/template/options'
require 'sinatra'
require 'sinatra/cookies'
require 'sass'
require 'net/http'
require 'uri'
require 'yaml'
require 'json'
require 'aws-sdk'
require 'stripe'
require 'time_difference'
require 'twitter'
require 'action_view'
require 'action_view/helpers'

require_relative 'version'
require_relative 'objects/exec'
require_relative 'objects/base'
require_relative 'objects/cookie'
require_relative 'objects/favicon'
require_relative 'objects/dynamo'
require_relative 'objects/github_auth'

configure do
  Haml::Options.defaults[:format] = :xhtml
  # Haml::Options.defaults[:autoclose] = %w(meta img link br hr input script)
  config = if ENV['RACK_ENV'] == 'test'
    {
      'cookie_secret' => 'test',
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
      'stripe' => {
        'live' => {
          'public_key' => 'test'
        }
      },
      'coupons' => ['test']
    }
  else
    YAML.load(File.open(File.join(Dir.pwd, 'config.yml')))
  end
  set :config, config
  set :oauth, GithubAuth.new(
    config['github']['client_id'],
    config['github']['client_secret']
  )
  set :base, Base.new(Dynamo.new(config).aws)
  set :twitter, (Twitter::REST::Client.new do |c|
    c.consumer_key = config['twitter']['consumer_key']
    c.consumer_secret = config['twitter']['consumer_secret']
    c.access_token = config['twitter']['access_token']
    c.access_token_secret = config['twitter']['access_token_secret']
  end)
end

before '/*' do
  @locals = {
    ver: VERSION,
    login_link: settings.oauth.login_uri
  }
  if cookies[:sixnines] || ENV['RACK_ENV'] == 'test'
    begin
      @locals[:user] = Cookie::Closed.new(
        cookies[:sixnines], settings.config['cookie_secret']
      ).to_s
    rescue OpenSSL::Cipher::CipherError => _
      @locals.delete(:user)
    end
  end
end

before '/a*' do
  redirect to('/') unless @locals[:user]
end

get '/oauth' do
  user = settings.oauth.user_name(settings.oauth.access_token(params[:code]))
  cookies[:sixnines] = Cookie::Open.new(
    user, settings.config['cookie_secret']
  ).to_s
  redirect to('/')
end

get '/logout' do
  cookies.delete(:sixnines)
  redirect to('/')
end

get '/terms' do
  haml :terms, layout: :layout, locals: @locals
end

get '/' do
  haml :index, layout: :layout, locals: @locals.merge(
    query: params[:q] ? params[:q] : nil,
    found: params[:q] ? settings.base.find(params[:q]) : [],
    flips: settings.base.flips
  )
end

get '/rss' do
  require 'rss'
  content_type 'application/rss+xml'
  RSS::Maker.make('atom') do |m|
    m.channel.author = 'SixNines.io'
    m.channel.updated = Time.now.to_s
    m.channel.about = 'http://sixnines.io/rss'
    m.channel.title = 'SixNines recent flips'
    settings.base.flips.each do |e|
      m.items.new_item do |i|
        i.link = "http://www.sixnines.io/h/#{e.to_h[:id]}"
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

# SVG badge of the endpoint
get '/b/:id' do
  begin
    response.headers['Cache-Control'] = 'no-cache, private'
    content_type 'image/svg+xml'
    EpBadge.new(settings.base.take(params[:id])).to_svg(
      params[:style] == 'flat' ? 'flat' : 'round'
    )
  rescue Base::EndpointNotFound
    404
  end
end

# History page of the endpoint
get '/h/:id' do
  begin
    haml :history, layout: :layout, locals: @locals.merge(
      e: Endpoint::Cached.new(settings.base.take(params[:id]))
    )
  rescue Base::EndpointNotFound
    404
  end
end

# SVG graph of the endpoint
get '/g/:id' do
  begin
    response.headers['Cache-Control'] = 'no-cache, private'
    content_type 'image/svg+xml'
    EpGraph.new(Endpoint::Cached.new(settings.base.take(params[:id]))).to_svg
  rescue Base::EndpointNotFound
    404
  end
end

# Favicon of the endpoint
get '/f/:id' do
  begin
    response.headers['Cache-Control'] = 'max-age=' + (5 * 60 * 60).to_s
    content_type 'image/png'
    Favicon.new(settings.base.take(params[:id]).to_h[:uri].host).png
  rescue Base::EndpointNotFound
    404
  end
end

get '/ping' do
  content_type 'text/plain'
  txt = ''
  again = false
  open('/tmp/sixnines.lock', 'w') do |f|
    txt << if f.flock(File::LOCK_NB | File::LOCK_EX)
      again = true
      settings.base.ping do |up, ep|
        next if ENV['RACK_ENV'] == 'test'
        href = 'http://www.sixnines.io' + EpBadge.new(ep).to_href
        settings.twitter.update(
          if up
            "#{ep.to_h[:hostname]} went back up! #{href}"
          else
            "#{ep.to_h[:hostname]} is down! #{href}"
          end
        )
      end
    else
      status(403)
      'Locked, try again a bit later'
    end
  end
  if txt.empty?
    status(204)
    again = true
  end
  if again
    Process.detach(
      fork do
        sleep(10)
        Net::HTTP.get_response(URI.parse('http://www.sixnines.io/ping?fork'))
      end
    )
  end
  txt
end

get '/robots.txt' do
  'sitemap: http://www.sixnines.io/sitemap.xml'
end

get '/version' do
  VERSION
end

get '/a' do
  haml :account, layout: :layout, locals: @locals.merge(
    endpoints: settings.base.endpoints(@locals[:user]).list,
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
    unless settings.config['coupons'].include?(params[:coupon])
      raise "Invalid coupon \"#{params[:coupon]}\""
    end
  end
  settings.base.endpoints(@locals[:user]).add(params[:endpoint])
  redirect to('/a')
end

get '/a/del' do
  settings.base.endpoints(@locals[:user]).del(params[:endpoint])
  redirect to('/a')
end

get '/css/*.css' do
  content_type 'text/css', charset: 'utf-8'
  file = params[:splat].first
  sass file.to_sym, views: "#{settings.root}/assets/sass"
end

not_found do
  status 404
  haml :not_found, layout: :layout, locals: @locals
end

error do
  status 503
  e = env['sinatra.error']
  haml(
    :error,
    layout: :layout,
    locals: @locals.merge(error: "#{e.message}\n\t#{e.backtrace.join("\n\t")}")
  )
end
