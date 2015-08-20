require 'sinatra'
require 'data_mapper'
require 'sinatra/reloader' if development?


DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/todo_list.db")
enable :sessions

class Item 
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :done, Boolean, :required => true, :default => false
  property :created, DateTime
  property :title, Text, :required => true
  property :description, Text
end

class Users
  include DataMapper::Resource
  property :id, Serial
  property :fullname, Text, :required => true
  property :email, Text, :required => true
  property :password, Text, :required => true
  property :confirmpassword, Text, :required => true
end


DataMapper.finalize.auto_upgrade!

get '/' do
   erb :home
end

get '/index' do
  @items = Item.all(:order => :created.desc)
  redirect '/new' if @items.empty?
  erb :index
end

post '/index' do
  @items = Item.all(:order => :created.desc)
  redirect '/new' if @items.empty?
  erb :index
end

get '/home' do
  erb :home
end

post '/home' do
   user = Users.first(:email => params[:email])
  if !user.nil? && user[:password] == params[:password]
   session[:email] == user[:email]
     redirect '/index'
 else
 #flash[:error] = "emailaddress and passwod Not in existence"
   redirect '/home'
end
end

get '/new' do
  @title = "Add Note"
  erb :new
end

get '/signup' do
  erb :signup
end
 
post '/signup' do
  Users.create(:fullname => params[:fullname], :email => params[:email], :password => params[:password], :confirmpassword => params[:confirmpassword])
  erb :signup
  redirect '/home'
end

post '/new' do
  Item.create(:title => params[:title], :content => params[:content], :created => Time.now)
  redirect '/index'
end

post '/done' do
  item = Item.first(:id => params[:id])
  item.done = !item.done
  item.save
  content_type 'application/json'
  value = item.done ? 'done' : 'not done'
  { :id => params[:id], :status => value }.to_json
end

get '/delete/:id' do
  @item = Item.first(:id => params[:id].to_i)
  erb :delete
end

delete '/delete/:id' do
  if params.has_key?("ok")
    item = Item.first(:id => params[:id].to_i)
    item.destroy
    redirect '/index'
  else
    redirect '/index'
  end
end