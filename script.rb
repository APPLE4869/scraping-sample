require 'redis'
Dir.glob('./src/**/*.rb').each { |file| require file }

def search(company_name, address, webpage_url)
  # 認証処理
  email = ENV['VORKERS_EMAIL']
  password = ENV['VORKERS_PASSWORD']
  auth = Vorkers::Auth.new
  auth.login(email: email, password: password)

  # 「会社名」で該当する会社IDを収集(配列)
  company_id_list_client = Vorkers::CompanyIdList.new(company_name)
  company_ids = company_id_list_client.fetch

  return company_ids

  # 住所と企業ホームページでIDを絞り込む
  company_id_filter = Vorkers::CompanyIdFilger.new(address: address, webpage_url: webpage_url)
  company_ids = company_id_filter.perform(company_ids)
end

File.open("data.txt", mode = "rt") do |f|
  f.each_line do |line|
    company_name = line.strip
    p "start : #{company_name}"
    company_ids = search(company_name, nil, nil)

    File.open("output.txt", "a") do |f|
      f.puts("#{company_name},#{company_ids.size},#{company_ids.join(",")}")
    end
    p "  -> #{company_name},#{company_ids.size},#{company_ids.join(",")}"
    p "end : #{company_name}"
  end
end
