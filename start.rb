require 'sinatra'

module Rack
  module Protection
    class HostAuthorization
      def call(env)
        @app.call(env)
      end
    end
  end
end

require 'faye/websocket'
require 'json'

APP_ROOT = File.expand_path(__dir__)

configure do
  set :bind, '0.0.0.0'
  set :port, 4568
  disable :protection
  set :protection, false
end

before do
  puts "=== REQUEST DEBUG ==="
  puts "Host: #{request.host}"
  puts "User-Agent: #{request.user_agent}"
  puts "All headers:"
  request.env.each {|k,v| puts "  #{k}: #{v}" if k.start_with?('HTTP_')}
  puts "===================="
end

$clients = {}
$players = {}

require_relative './helpers/broadcast'

require_relative './routes/index'
require_relative './routes/websocket'