#!/usr/bin/env ruby

require 'optparse' # Call OptionParse class for command-line option analysis
require File.expand_path('../../lib/memcached/memcached_server', __FILE__)

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: memcached_server [options]'

  opts.on('-p', '--port port', 'Port') do |each|
    options[:port] = each
  end
end.parse!

options[:port] ||= 2000
my_server = MyServer.new(options[:port]) # Socket to listen on port 2000
my_server.start