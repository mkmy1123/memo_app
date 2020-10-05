require 'sinatra'
require 'sinatra/reloader'

# root page
get "/" do
  erb :root
end
