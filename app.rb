# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'date'

# root page
get '/' do
  @memos = get_all_memo
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
  get_html_body(@memo)
  erb :show
end

get '/memo/:id/edit' do
  get_memo(params[:id])
  erb :edit
end

patch '/memo/:id/edit' do
  get_memo(params[:id])
  update(params[:id], params[:title], params[:body])
  redirect "/memo/#{params[:id]}"
end

delete '/memo/:id/delete' do
  delete(params[:id])
  redirect '/'
end

# ---- ACTIONS ---- 
def create(title, body)
  sql =<<~SQL
    INSERT INTO memo(id, title, body, updated_at, created_at)
    VALUES(DEFAULT, $1, $2, now(), now())
  SQL
  conn = PG.connect( dbname: 'memo_db', user: 'postgres' )
  conn.exec(sql, [title, body])
end

def update(id, title, body)
  sql =<<~SQL
    UPDATE memo
    SET title = $1,
        body = $2,
        updated_at = now()
    WHERE id = #{id}
  SQL
  conn = PG.connect( dbname: 'memo_db', user: 'postgres' )
  conn.exec(sql, [title, body])
end

def delete(id)
  conn = PG.connect( dbname: 'memo_db', user: 'postgres' )
  conn.exec( "DELETE FROM memo WHERE id = #{id}" )
end

# ---- GET DATA'S METHOD -----
def get_all_memo
  conn = PG.connect( dbname: 'memo_db' )
  memos = []
  conn.exec( "SELECT * FROM memo" ) do |result|
    result.each do |row|
      memos << row
    end
  end
  memos
end

def get_memo(id)
  conn = PG.connect( dbname: 'memo_db' )
  conn.exec( "SELECT * FROM memo WHERE id = #{id}" ) do |result|
    result.each do |row|
      @memo = row
    end
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
  memo['body'] = array.join
end
