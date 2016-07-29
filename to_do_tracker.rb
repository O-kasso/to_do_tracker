require 'sinatra'
require 'data_mapper'
require 'tilt/erb'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/to_do_tracker.db")

class Note
  include DataMapper::Resource
  property :id, Serial 
  property :content, Text, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

helpers do
  # so we can use escape_html method
  include Rack::Utils
end

get '/' do
  @notes = Note.all :order => :id.desc
  @title = 'All Notes'
  erb :home
end

post '/' do
  n = Note.new
  n.content = params[:content]
  n.created_at = Time.now
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/:id' do
  @note = Note.get params[:id]
  @title = "Edit note ##{params[:id]}"
  erb :edit
end

put '/:id' do
  n = Note.get params[:id]
  n.content = params[:content]
  n.complete = params[:complete] ? 1 : 0 
  # complete param only exists if checkbox was checked when form was submitted
  # therefore set bool depending on whether it exists
  n.updated_at = Time.now
  n.save
  redirect '/'
end

get '/:id/delete' do
  @note = Note.get params[:id]
  @title = "Confirm deletion of note ##{params[:id]}"
  erb :delete
end

delete '/:id' do
  n = Note.get params[:id]
  n.destroy
  redirect '/'
end

get '/:id/complete' do
  n = Note.get params[:id]
  # reverse complete status
  n.complete = n.complete ? 0 : 1
  n.updated_at = Time.now
  n.save
  redirect '/'
end
