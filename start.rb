require 'sinatra'
require 'faye/websocket'
require 'json'

APP_ROOT = File.expand_path(__dir__)

set :bind, '0.0.0.0'
set :port, 4568

$clients = {}
$players = {}

require_relative './helpers/broadcast'

require_relative './routes/index'
require_relative './routes/websocket'