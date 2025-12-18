# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'simplecov'
require 'simplecov-cobertura'
unless SimpleCov.running
  SimpleCov.command_name('test')
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::CoberturaFormatter
    ]
  )
  SimpleCov.minimum_coverage 85
  SimpleCov.minimum_coverage_by_file 65
  SimpleCov.start do
    add_filter 'test/'
    add_filter 'vendor/'
    add_filter 'target/'
    track_files 'lib/**/*.rb'
    track_files '*.rb'
  end
end

require 'minitest/autorun'
require 'minitest/reporters'
require 'rack/test'
require 'webmock/minitest'
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
Minitest.load :minitest_reporter
