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

require 'net/http'
require 'uri'
require 'yaml'
require 'json'

#
# GitHub auth mechanism
#
class GithubAuth
  def initialize(id, secret)
    @id = id
    @secret = secret
  end

  def login_uri
    'https://github.com/login/oauth/authorize?client_id=' +
      @id + '&redirect_uri=http://www.sixnines.io/oauth'
  end

  def access_token(code)
    uri = URI.parse('https://github.com/login/oauth/access_token')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(
      'code' => code,
      'client_id' => @id,
      'client_secret' => @secret
    )
    req['Accept'] = 'application/json'
    res = http.request(req)
    raise "Failed to fetch access token: #{res.body}" unless res.code == 200
    puts res.body
    JSON.parse(res.body)['access_token']
  end

  def user_name(token)
    uri = URI.parse('https://api.github.com/user?access_token=' + token)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Accept-Header'] = 'application/json'
    res = http.request(req)
    JSON.parse(res.body)['login']
  end
end
