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

require 'yaml'
require 'aws-sdk'

#
# Dynamo client
#
class Dynamo
  def initialize(config = {})
    @config = config
  end

  def aws
    Aws::DynamoDB::Client.new(
      if ENV['RACK_ENV'] == 'test'
        cfg = File.join(Dir.pwd, 'dynamodb-local/target/dynamo.yml')
        raise 'Test config is absent' unless File.exist?(cfg)
        yaml = YAML.load(File.open(cfg))
        {
          region: 'us-east-1',
          endpoint: "http://localhost:#{yaml['port']}",
          access_key_id: yaml['key'],
          secret_access_key: yaml['secret'],
          http_open_timeout: 5,
          http_read_timeout: 5
        }
      else
        {
          region: @config['dynamodb']['region'],
          access_key_id: @config['dynamodb']['key'],
          secret_access_key: @config['dynamodb']['secret']
        }
      end
    )
  end
end
