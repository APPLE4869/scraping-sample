# coding: utf-8
require 'sinatra'

Dir.glob('./src/**/*.rb').each { |file| require file }

get '/company/:company_name' do
  p params[:company_name]
  v = Vorkers.new("クラウドワークス")
  info = v.fetch_corporate_info
  @info = info
  erb :index
end
