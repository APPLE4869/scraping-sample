# coding: utf-8
require 'sinatra'

Dir.glob('./src/**/*.rb').each { |file| require file }

get '/company/:company_name' do
  cache_control :public, max_age: 3600

  company_id_list_client = Vorkers::CompanyIdList.new(params[:company_name])
  company_ids = company_id_list_client.fetch

  @company_info_list = {}
  company_ids.each do |company_id|
    fetcher = Vorkers::Fetcher.new(company_id)
    @company_info_list[company_id] = fetcher.perform
  end

  erb :index
end
