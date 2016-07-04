require 'rubygems'
require 'bundler'

Bundler.require

require './to_do_tracker'
run Sinatra::Application
