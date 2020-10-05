# encoding: utf-8
require 'sinatra'
require 'sinatra/reloader'
require 'json'

FILE_PATH = "memo/data.json"

# root page
get "/" do
  @memos = all_memo
  erb :root
end

get "/new" do
  erb :new
end

post "/memo" do
  create(params[:title], params[:body])
  redirect '/'
end

def create(title, body)
  File.open(FILE_PATH, "a", 0755) do |file|
    id = all_memo.last["id"] + 1
    json =<<~JSON
    { "id": #{id}, "title": "#{title}", "body": "#{body}" }
    JSON
    file.puts json
  end
end

def all_memo
  File.readlines(FILE_PATH).map do |json|
    JSON.parse(json)
  end
end
