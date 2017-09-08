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

require 'uri'
require 'timeout'
require 'net/http'
require 'openssl'
require_relative 'resource'

#
# Proxied single web resource.
#
class ProxiedResource
  def initialize(resource, proxies = [''])
    @resource = resource
    @proxies = proxies
  end

  def take
    a = [500, '', 'There are no proxies']
    @proxies.each do |p|
      host, port = p.split(':')
      begin
        a = @resource.take(host, port)
      rescue Net::HTTPServerException => e
        code = e.message.split(' ')[0].to_i
        raise e unless code == 407
        a = Response.new(200, '', e.message).receive
      end
      break if a[0] != 500 || !a[1].empty?
    end
    a
  end
end
