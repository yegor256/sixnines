# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'webmock/test_unit'
WebMock.allow_net_connect!
