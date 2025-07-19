require 'sinatra'
require 'faye/websocket'
require 'json'
require 'chunky_png'

APP_ROOT = File.expand_path(__dir__)
DEBUG = false

configure do
  set :bind, '0.0.0.0'
  set :port, 4568
  set :public_folder, File.expand_path('public', __dir__)
  set :environment, :production
  disable :protection
end

if DEBUG
    before do
    puts "=== REQUEST DEBUG ==="
    puts "Host: #{request.host}"
    puts "User-Agent: #{request.user_agent}"
    puts "All headers:"
    request.env.each {|k,v| puts "  #{k}: #{v}" if k.start_with?('HTTP_')}
    puts "===================="
    end
end

$clients = {}
$players = {}

require_relative './helpers/broadcast'
require_relative './helpers/room'

require_relative './routes/index'
require_relative './routes/websocket'
require_relative './routes/tile'