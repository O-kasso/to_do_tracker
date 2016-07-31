require 'sinatra'
require 'data_mapper'
require 'tilt/erb'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

enable :sessions

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

get '/' do
  @notes = Note.all :order => :id.desc
  @title = 'All Notes'
  flash[:error] = 'No notes found. Add your first below.' if @notes.empty?
  erb :home
end

post '/' do
  n = Note.new
  n.content = params[:content]
  n.created_at = Time.now
  n.updated_at = Time.now
  if n.save
    redirect '/', notice: 'Note created successfully.'
  else
    redirect '/', error: 'Failed to save note.'
  end
end

get '/:id' do
  @note = Note.get params[:id]
  @title = "Edit note ##{params[:id]}"
  if @note
    erb :edit
  else
    redirect '/', error: 'Cannot find note.'
  end
end

put '/:id' do
  n = Note.get params[:id]
  unless n
    redirect '/', error: 'Cannot find note.'
  end
  n.content = params[:content]
  n.complete = params[:complete] ? 1 : 0 
  # complete param only exists if checkbox was checked when form was submitted
  # therefore set bool depending on whether it exists
  n.updated_at = Time.now
  if n.save
    redirect '/', notice: 'Note updated successfully.'
  else
    redirect '/', error: 'Error updating note.'
  end
end

get '/:id/delete' do
  @note = Note.get params[:id]
  @title = "Confirm deletion of note ##{params[:id]}"
  if @note
    erb :delete
  else
    redirect '/', error: 'Cannot find note.'
  end
end

delete '/:id' do
  n = Note.get params[:id]
  if n.destroy
    redirect '/', notice: 'Note deleted successfully.'
  else
    redirect '/', error: 'Error deleting note.'
  end
end

get '/:id/complete' do
  n = Note.get params[:id]
  redirect '/', error: 'Cannot find note.' unless n
  # reverse complete status
  n.complete = n.complete ? 0 : 1
  n.updated_at = Time.now
  if n.save
    redirect '/', notice: 'Note marked as complete.'
  else
    redirect '/', error: 'Error marking note as complete.'
  end
end
