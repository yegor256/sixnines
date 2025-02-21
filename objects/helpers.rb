# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'action_view'
require 'action_view/helpers'

# rubocop:disable Style/MixinUsage
include ActionView::Helpers::DateHelper
# rubocop:enable Style/MixinUsage

helpers do
  def time_ago(time)
    time_ago_in_words(time)
  end
end
