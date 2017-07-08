#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'Leprosorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db


	@db.execute 'CREATE TABLE IF NOT EXISTS Posts 
	(
	    id           INTEGER PRIMARY KEY AUTOINCREMENT,
	    Created_date DATE,
	    Content      TEXT
	)'


end


get '/' do

	@results = @db.execute 'select * from posts order by id desc'
	erb :index
end

get '/something' do
   erb :new
end


post '/new' do

	content = params[:content]


	if content.length <= 0
		@error ='Type text'
		return erb :new
	end

	@db.execute 'insert into posts (content, created_date) values (?, datetime())', [content]


	erb "You typed #{content}"
end