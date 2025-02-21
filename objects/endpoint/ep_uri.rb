# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
