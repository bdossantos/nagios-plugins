#!/usr/bin/env ruby
#
# Twemproxy Status Check using JSON status page
#
# (c) Wanelo Inc, Distributed under Apache License
#
# Usage: ./check_twemproxy [-h host] [-p port]
#
# Dependencies: ruby with JSON parser installed.
#
# Returns OK/SUCCESS when all servers in the sharded cluster are connected, or
# CRITICAL otherwise.
#

require 'optparse'
require 'json'

# Nagios return codes
STATE_OK = 0
STATE_WARNING = 1
STATE_CRITICAL = 2
STATE_UNKNOWN = 3

options = Struct.new('Options', :host, :port).new
options.port = 22_222
options.host = '127.0.0.1'

optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: check_twemproxy [-h host] [-p port]'

  opts.on('-h', '--host HOST', String, 'Host name or IP address') do |h|
    options.host = h
  end

  opts.on('-p', '--port PORT', Integer, 'Port') do |p|
    options.port = p
  end

  opts.on('-?', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

begin
  optparse.parse!
  fail OptionParser::MissingArgument.new('host is required') unless options.host
rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
  puts e.message
  puts optparse
  exit STATE_UNKNOWN
end

begin
  firstrun = JSON.parse(`nc #{options.host} #{options.port} 2>/dev/null`)
  secondrun = JSON.parse(`nc #{options.host} #{options.port} 2>/dev/null`)
rescue
  puts 'CRITICAL - timed out connecting to twemproxy on ' \
       "#{options.host}:#{options.port}"
end

errors = {}
error_clusters = {}
secondrun.keys.select { |k| secondrun[k].is_a?(Hash) }.each do |cluster|
  secondrun[cluster].keys.select { |v| secondrun[cluster][v].is_a?(Hash) }.each do |server|
    next if secondrun[cluster][server]['server_connections'].to_i > 0
    next if secondrun[cluster][server]['requests'].to_i - \
            firstrun[cluster][server]['requests'].to_i == 0

    errors[server] = 1
    error_clusters[cluster] = 1
  end
end

unless error_clusters.empty?
  problem = <<-END
    error with redis cluster [#{error_clusters.keys.join(',')}]
    problem shards: #{errors.keys.join(',')}
  END
end

if problem.nil?
  puts "TWEMPROXY OK : #{options.host}"
  exit STATE_OK
else
  puts "TWEMPROXY CRITICAL : #{options.host} #{problem}"
  exit STATE_CRITICAL
end
