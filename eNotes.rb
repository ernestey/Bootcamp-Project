require 'sinatra'
require 'data_mapper'
require 'sinatra/reloader' if development?
enable :sessions


DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/eNotes.db")



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
   session[:fullname] == user[:fullname]
     redirect '/index'
 else
 @error = "username and password do not exist. Return home and signup"#flash[:error] = "emailaddress and passwod Not in existence"

end
end

get '/new' do
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

get '/delete/:id' do
  @item = Item.first(:id => params[:id].to_i)
  erb :delete
end

get '/:id' do
  Item.get params[:id]
  erb :edit
end


get '/edit/:id' do
  @item = Item.first(:id => params[:id], :content => params[:content], :created => [:created])
  erb :edit
  redirect '/index'
end

put '/edit/:id' do
  Item.get(:id => params[:id], :content => params[:content], :created => [:created])
  erb :edit
  redirect '/index'
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