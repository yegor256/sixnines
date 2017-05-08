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

require 'openssl'
require 'digest/sha1'
require 'base64'

#
# Secure cookie
#
class Cookie
  # Closed
  class Closed
    def initialize(text, secret)
      @text = text
      @secret = secret
    end

    def to_s
      if @secret.empty?
        @text
      else
        cpr = Cookie.cipher
        cpr.decrypt
        cpr.key = Digest::SHA1.hexdigest(@secret)
        decrypted = cpr.update(Base64.decode64(@text))
        decrypted << cpr.final
        decrypted.to_s
      end
    end
  end

  # Open
  class Open
    def initialize(text, secret)
      @text = text
      @secret = secret
    end

    def to_s
      cpr = Cookie.cipher
      cpr.encrypt
      cpr.key = Digest::SHA1.hexdigest(@secret)
      encrypted = cpr.update(@text)
      encrypted << cpr.final
      Base64.encode64(encrypted.to_s)
    end
  end

  def self.cipher
    OpenSSL::Cipher::Cipher.new('aes-256-cbc')
  end
end
