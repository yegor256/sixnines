# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'socket'

class FakeServer
  def start(code)
    server = TCPServer.new('127.0.0.1', 0)
    port = server.addr[1]
    Thread.start do
      Kernel.loop do
        session = server.accept
        session.gets
        session.print "HTTP/1.1 #{code}\r\n"
        session.print "Content-type: text/plain\r\n"
        session.print "\r\n"
        session.print "Some content here\r\n"
        session.close
      end
    end
    port
  end
end
