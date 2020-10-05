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

get "/memo/:id" do
  get_memo(params[:id])
  erb :show
end

delete "/memo/:id/delete" do
  deleted = all_memo.delete_if { |memo| p memo["id"] == params[:id].to_i }
  File.open(FILE_PATH, "w", 0755) do |file|
    deleted.map! do |memo|
      json = memo.to_json
      file.puts json
    end
  end
  redirect '/'
end

def get_memo(id)
  id = id.to_i
  all_memo.each do |memo|
    if memo["id"] == id
      @memo = memo
    end
  end
end

def create(title, body)
  File.open(FILE_PATH, "a", 0755) do |file|
    id = all_memo.none? ? 1 : all_memo.last["id"] + 1
    json =<<~JSON
    { "id": #{id}, "title": "#{title}", "body": #{body.dump} }
    JSON
    file.puts json
  end
end

def all_memo
  File.readlines(FILE_PATH).map do |json|
    JSON.parse(json)
  end
end
