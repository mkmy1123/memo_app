require 'sinatra'
require 'sinatra/reloader'

# root page
get "/" do
  @memos = all_memo("memo")
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
  File.open("memo/#{title}", "w", 0755) { |f| f.print body }
end

def all_memo(folder_name)
  memos = []
  Dir.open(folder_name).each do |file|
    unless file[0] == "."
      memos << {
        title: file,
        body: file
      }
    end
  end
  memos
end
