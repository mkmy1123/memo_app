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
  @memo["body"] = get_html_body(@memo)
  erb :show
end

get "/memo/:id/edit" do
  get_memo(params[:id])
  erb :edit
end

patch "/memo/:id/edit" do
  memos = all_memo
  update(memos, params[:id])
  redirect "/memo/#{params[:id]}"
end

delete "/memo/:id/delete" do
  memos = all_memo
  delete(memos, params[:id])
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

def get_html_body(memo)
  array = []
  memo["body"].lines do |line|
    if line == "\r\n"
      array << "<br>"
    else
      array << "<p>#{line}</p>"
    end
  end
  array.join
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

def update(memos, id)
  File.open(FILE_PATH, "w", 0755) do |file|
    memos.each do |memo|
      if memo["id"] == id.to_i
        json =<<~JSON
        { "id": #{id}, "title": "#{params[:title]}", "body": #{params[:body].dump} }
        JSON
        file.puts json
      else
        json = memo.to_json
        file.puts json
      end
    end
  end
end

def delete(memos, id)
  memos = memos.delete_if { |memo| memo["id"] == id.to_i }
  File.open(FILE_PATH, "w", 0755) do |file|
    memos.map! do |memo|
      json = memo.to_json
      file.puts json
    end
  end
end

def all_memo
  File.readlines(FILE_PATH).map do |json|
    JSON.parse(json)
  end
end
