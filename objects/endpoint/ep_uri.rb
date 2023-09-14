# frozen_string_literal: true

# Copyright (c) 2017-2023 Yegor Bugayenko
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

require 'cgi'

#
# URI of endpoint
#
class EpUri
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def to_s
    @endpoint.to_h[:uri].to_s
  end

  def to_url
    CGI.escape(to_s)
  end

  def favicon(size = 'small')
    "<img class='favicon-#{size}' src='/f/#{@endpoint.to_h[:id]}' alt='icon'/>"
  end

  def to_html
    "<a href='#{self}'>#{@endpoint.to_h[:hostname]}</a>"
  end
end
