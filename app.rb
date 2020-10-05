# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

FILE_PATH = 'memo/data.json'

# root page
get '/' do
  @memos = all_memo
  erb :root
end

get '/new' do
  erb :new
end

post '/memo' do
  create(params[:title], params[:body])
  redirect '/'
end

get '/memo/:id' do
  get_memo(params[:id])
  @memo['body'] = get_html_body(@memo)
  erb :show
end

get '/memo/:id/edit' do
  get_memo(params[:id])
  erb :edit
end

patch '/memo/:id/edit' do
  memos = all_memo
  update(memos, params[:id])
  redirect "/memo/#{params[:id]}"
end

delete '/memo/:id/delete' do
  memos = all_memo
  delete(memos, params[:id])
  redirect '/'
end

def is_equal_id(memo, id)
  memo['id'] == id.to_i
end

def get_memo(id)
  all_memo.each do |memo|
    @memo = memo if is_equal_id(memo, id)
  end
end

def get_html_body(memo)
  array = memo['body'].lines.map do |line|
    if line == "\r\n"
      '<br>'
    else
      "<p>#{line}</p>"
    end
  end
  array.join
end

def to_json_style(id, title, body)
  <<~JSON
    { "id": #{id}, "title": "#{title}", "body": #{body} }
  JSON
end

def create(title, body)
  File.open(FILE_PATH, 'a', 0o755) do |file|
    id = all_memo.none? ? 1 : all_memo.last['id'] + 1
    json = to_json_style(id, title, body.dump)
    file.puts json
  end
end

def update(memos, id)
  File.open(FILE_PATH, 'w', 0o755) do |file|
    memos.each do |memo|
      json = is_equal_id(memo, id) ? to_json_style(id, params[:title], params[:body].dump) : memo.to_json
      file.puts json
    end
  end
end

def delete(memos, id)
  memos = memos.delete_if { |memo| is_equal_id(memo, id) }
  File.open(FILE_PATH, 'w', 0o755) do |file|
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
