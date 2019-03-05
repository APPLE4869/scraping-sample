# coding: utf-8
module Vorkers
  class CompanyIdList
    def initialize(company_name)
      raise ArgumentError unless company_name.kind_of?(String)
      @company_name = company_name
    end

    # Vorkersの企業IDを取得
    def fetch
      list_doc = scraping_client.fetch_doc(company_list_path)

      company_id_list = []
      list_doc.xpath('//div[@class="searchCompanyName"]').each do |node|
        href = node.css('a').attribute('href').value
        m = href.match(/.+?m_id=([A-Za-z0-9]+)/)
        company_id_list << m[1]
      end

      company_id_list
    end

    private

    def scraping_client
      @scraping_client ||= Scraping.new(BASE_URL)
    end

    def company_list_path
      URI.escape("/company_list?field=&pref=&src_str=#{@company_name}&sort=1&ct=comlist")
    end
  end
end
