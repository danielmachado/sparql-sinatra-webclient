# myapp.rb
require 'rubygems'
require 'sinatra'
require './model/triplet.rb'
require './lib/sparql_manager.rb'

# Defines a configuration to allow aplication access to the static content (js,css,img...)
configure do
	set :public_folder, Proc.new { File.join(root, "static") }
end

# Listen petitions on '/' (home) of the site
get '/' do
	erb :index
end

# Listen petitions on '/about' of the site
get '/about' do
	erb :about
end

# Listen petitions on '/visualization' of the site
get '/visualization' do
	manager = SPARQLManager.new
	
	@query_1 = manager.top_ten_diseases
	@query_2 = manager.electric_disease_relation
	@query_3 = manager.diseases_census_ratio
	@query_4 = manager.afected_facilities_ratio
	
	erb :visualization
end