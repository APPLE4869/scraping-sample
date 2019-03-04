Dir.glob('./src/**/*.rb').each { |file| require file }

company_name = "クラウドワークス"
v = Vorkers.new(company_name)
v.fetch_corporate_info
