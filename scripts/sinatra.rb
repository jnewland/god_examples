require 'rubygems'
require 'sinatra'

get '/' do
  Time.now.utc.to_s
end

get '/heartbeat' do
  if rand(5) == 1
    status(500)
    'ERROR'
  else
    'OK'
  end
end