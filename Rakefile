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

require 'rubygems'
require 'rake'
require 'rdoc'
require 'rake/clean'
require 'yaml'
require 'aws-sdk'

task default: [:clean, :test, :rubocop, :copyright]

require 'rake/testtask'
desc 'Run all unit tests'
Rake::TestTask.new(:test => :dynamo) do |test|
  Rake::Cleaner.cleanup_files(['coverage'])
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = false
end

require 'rubocop/rake_task'
desc 'Run RuboCop on all directories'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
  task.requires << 'rubocop-rspec'
end

task :dynamo do
  cfg = File.join(Dir.pwd, 'dynamodb-local/target/dynamo.yml')
  File.delete(cfg) if File.exist?(cfg)
  pid = Process.spawn(
    'mvn', '--quiet', 'install',
    chdir: 'dynamodb-local',
  )
  END {
    `kill -TERM #{pid}`
    puts "DynamoDB Local killed in PID #{pid}"
  }
  begin
    yaml = YAML.load(File.open(cfg))
    puts 'Table status: ' + Aws::DynamoDB::Client.new(
      region: 'us-east-1',
      endpoint: "http://localhost:#{yaml['port']}",
      access_key_id: yaml['key'],
      secret_access_key: yaml['secret'],
      http_open_timeout: 5,
      http_read_timeout: 5
    ).describe_table(table_name: 'sn-endpoints')[:table][:table_status]
  rescue
    retry
  end
  puts "DynamoDB Local is running in PID #{pid}, port=#{yaml['port']}"
end

task :copyright do
  sh "grep -q -r '#{Date.today.strftime('%Y')}' \
    --include '*.rb' \
    --include '*.txt' \
    --include 'Rakefile' \
    ."
end
