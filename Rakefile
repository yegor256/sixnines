# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'rubygems'
require 'fileutils'
require 'rake'
require 'rdoc'
require 'rake/clean'
require_relative 'objects/dynamo'

ENV['RACK_ENV'] = 'test'

task default: %i[clean test rubocop copyright]

require 'rake/testtask'
Rake::TestTask.new(test: :dynamo) do |test|
  Rake::Cleaner.cleanup_files(['coverage'])
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = false
  test.warning = false
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
  task.requires << 'rubocop-rspec'
end

desc 'Start DynamoDB Local server'
task :dynamo do
  FileUtils.rm_rf('dynamodb-local/target')
  pid = Process.spawn('mvn', 'install', chdir: 'dynamodb-local')
  at_exit do
    `kill -TERM #{pid}`
    puts "DynamoDB Local killed in PID #{pid}"
  end
  begin
    status = Dynamo.new.aws.describe_table(
      table_name: 'sn-endpoints'
    )[:table][:table_status]
    puts "DynamoDB Local table: #{status}"
  rescue Exception => e
    puts e.message
    sleep(5)
    retry
  end
  puts "DynamoDB Local is running in PID #{pid}"
end

desc 'Sleep endlessly after the start of DynamoDB Local server'
task :sleep do
  loop do
    sleep(5)
    puts 'Still alive...'
  end
end

task run: :dynamo do
  `rerun -b "RACK_ENV=test rackup"`
end

task :copyright do
  sh "grep -q -r '2017-#{Date.today.strftime('%Y')}' \
    --include '*.rb' \
    --include '*.txt' \
    --include 'Rakefile' \
    ."
end
