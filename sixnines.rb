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
require 'sinatra'
require 'sinatra/cookies'
require 'sass'
require 'net/http'
require 'uri'
require 'yaml'
require 'json'
require 'aws-sdk'

require_relative 'version'
require_relative 'objects/exec'
require_relative 'objects/base'
require_relative 'objects/cookie'
require_relative 'objects/github_auth'

configure do
  config = if ENV['RACK_ENV'] == 'test'
    {
      'cookie_secret' => 'nothing',
      'github' => {
        'client_id' => 'nothing',
        'client_secret' => 'nothing'
      },
      'dynamodb' => {
        'region' => 'us-east-1',
        'key' => 'nothing',
        'secret' => 'nothing'
      }
    }
  else
    name = '/code/home/assets/sixnines/config.yml'
    name = File.join(Dir.pwd, 'config.yml') unless File.exist?(name)
    YAML.load(File.open(name))
  end
  set :config, config
  set :oauth, GithubAuth.new(
    config['github']['client_id'],
    config['github']['client_secret']
  )
  set :base, Base.new(
    Aws::DynamoDB::Client.new(
      region: config['dynamodb']['region'],
      access_key_id: config['dynamodb']['key'],
      secret_access_key: config['dynamodb']['secret']
    )
  )
end

before '/*' do
  @locals = {
    ver: VERSION,
    login_link: settings.oauth.login_uri
  }
  if cookies[:sixnines]
    begin
      @locals[:user] = Cookie::Closed.new(
        cookies[:sixnines], settings.config['cookie_secret']
      ).to_s
    rescue OpenSSL::Cipher::CipherError => _
      @locals.delete(:user)
    end
  end
end

before '/a/*' do
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

get '/' do
  haml :index, layout: :layout, locals: @locals.merge(
    query: params[:q] ? params[:q] : nil,
    found: params[:q] ? settings.base.find(params[:q]) : [],
    flips: ENV['RACK_ENV'] == 'test' ? [] : settings.base.flips
  )
end

get '/b/:id' do
  response.headers['Cache-Control'] = 'no-cache, private'
  content_type 'image/svg+xml'
  EpBadge.new(settings.base.take(params[:id])).to_svg
end

get '/h/:id' do
  haml :history, layout: :layout, locals: @locals.merge(
    e: settings.base.take(params[:id])
  )
end

get '/g/:id' do
  response.headers['Cache-Control'] = 'no-cache, private'
  content_type 'image/svg+xml'
  EpGraph.new(settings.base.take(params[:id])).to_svg
end

get '/ping' do
  content_type 'text/plain'
  txt = ''
  again = false
  open('/tmp/sixnines.lock', 'w') do |f|
    txt << if f.flock(File::LOCK_NB | File::LOCK_EX)
      again = true
      settings.base.ping
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
  ''
end

get '/version' do
  VERSION
end

get '/a' do
  haml :account, layout: :layout, locals: @locals.merge(
    endpoints: settings.base.endpoints(@locals[:user]).list
  )
end

post '/a/add' do
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
  haml(
    :error,
    layout: :layout,
    locals: @locals.merge(error: env['sinatra.error'].message)
  )
end
