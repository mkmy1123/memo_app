# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'date'

# --- DB CONFIG ---
configure do
  set :db_connect, PG.connect(
    user: 'postgres', dbname: 'memo_db'
  )
end

# ---- ROUTING -----
get '/' do
  @memos = find_all_memos
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
  @memo = find_memo(params[:id])
  to_html_body(@memo)
  p @memo
  erb :show
end

get '/memo/:id/edit' do
  @memo = find_memo(params[:id])
  erb :edit
end

patch '/memo/:id/edit' do
  update(params[:id], params[:title], params[:body])
  redirect "/memo/#{params[:id]}"
end

delete '/memo/:id/delete' do
  delete(params[:id])
  redirect '/'
end

# ---- ACTIONS ----
def create(title, body)
  sql = <<~SQL
    INSERT INTO memo(id, title, body, updated_at, created_at)
    VALUES(DEFAULT, $1, $2, now(), now())
  SQL
  settings.db_connect.exec(sql, [title, body])
end

def update(id, title, body)
  sql = <<~SQL
    UPDATE memo
    SET title = $1,
        body = $2,
        updated_at = now()
    WHERE id = #{id}
  SQL
  settings.db_connect.exec(sql, [title, body])
end

def delete(id)
  settings.db_connect.exec("DELETE FROM memo WHERE id = #{id}")
end

# ---- GET DATA'S METHOD -----
def find_all_memos
  settings.db_connect.exec('SELECT * FROM memo')
end

def find_memo(id)
  sql = <<~SQL
    SELECT * FROM memo WHERE id = #{id}
  SQL
  settings.db_connect.exec(sql).first
end

# ---- ARRANGE DATA ----
def to_html_body(memo)
  array = memo['body'].lines.map do |line|
    line.gsub!("\r\n", '<br>')
    line.gsub(' ', '&nbsp;')
  end
  memo['body'] = '<p>' + array.join + '</p>'
end
