Dir.glob('./src/**/*.rb').each { |file| require file }

company_name = "クラウドワークス"
company_id_list_client = Vorkers::CompanyIdList.new(company_name)
company_ids = company_id_list_client.fetch
company_ids.each do |company_id|
  fetcher = Vorkers::Fetcher.new(company_id)
  p fetcher.perform
end
