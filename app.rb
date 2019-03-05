# coding: utf-8
require 'sinatra'

Dir.glob('./src/**/*.rb').each { |file| require file }

get '/company/:company_name' do
  email = ENV['VORKERS_EMAIL']
  password = ENV['VORKERS_PASSWORD']

  # 認証処理
  auth = Vorkers::Auth.new
  auth.login(email: email, password: password)

  # 「会社名」で該当する会社IDを収集(配列)
  company_id_list_client = Vorkers::CompanyIdList.new(params[:company_name])
  company_ids = company_id_list_client.fetch

  # 収集した会社IDごとに会社情報を収集
  @company_info_list = {}
  company_ids.each do |company_id|
    fetcher = Vorkers::Fetcher.new(company_id)
    @company_info_list[company_id] = fetcher.perform
  end

  erb :index
end
