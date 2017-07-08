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
	    Content      TEXT,
	    author		 TEXT
	)'

	@db.execute 'CREATE TABLE IF NOT EXISTS Comments 
	(
	    id           INTEGER PRIMARY KEY AUTOINCREMENT,
	    Created_date DATE,
	    Content      TEXT,
	    post_id 	 INTEGER
	)'	


end


get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index
end

get '/something' do
   erb :new
end


post '/new' do

	content = params[:content]
	author = params[:author]

	hh = { 	:author => 'Введите имя',
			:content => 'Введите текст сообщения'}

	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

	if @error != ''
		return erb :new
	end


	@db.execute 'insert into posts 
		(
			content, 
			created_date, 
			author
		) 
			values 
		(
			?, 
			datetime(),
			?)', [content, author]

	redirect to '/'
	
end



get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where id = ?', [post_id]

	@row = results[0]

	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details
end


post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]

	@db.execute 'insert into Comments 
		(
			content, 
			created_date, 
			post_id
		) 
			values 
		(
			?, 
			datetime(),
			?
		)', [content, post_id]

		redirect to ('/details/' + post_id)
	
end