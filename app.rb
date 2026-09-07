require 'bundler/setup'
require 'sinatra'
require 'mail'

set :bind, '0.0.0.0'
set :port, 58080

get '/' do
  'Hello, world!'
end