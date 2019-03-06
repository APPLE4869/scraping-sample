# coding: utf-8
module Vorkers
  class CompanyIdFilger
    def initialize(address:, webpage_url:)
      @address = address
      @webpage_url = webpage_url
    end

    def perform(company_ids)
      raise ArgumentError unless company_ids.kind_of?(Array)

      return company_ids if company_ids.size == 0 || (@address == nil && @webpage_url == nil)

      filtered_company_ids = []

      company_ids.each do |company_id|
        fetched_address = fetch_address_by_company_id(company_id)
        fetched_webpage_url = fetch_webpage_url_by_company_id(company_id)

        if fetched_address == nil && fetched_webpage_url == nil
          filtered_company_ids << company_id
          next
        end

        if fetched_address == @address || fetched_webpage_url == @webpage_url
          filtered_company_ids << company_id
          next
        end
      end

      filtered_company_ids
    end

    private

    def same_address?(address1, address2)
      delete_extra_char(address1) == delete_extra_char(address2)
    end

    def same_website_url?(url1, url2)
      delete_extra_char(address1).sub(/\/$/, "") == delete_extra_char(address2).sub(/\/$/, "")
    end

    # 余分な文字を削除
    def delete_extra_char(str)
      str&.strip&.gsub(" ", "")&.gsub("　", "")
    end

    def fetch_address_by_company_id(company_id)
      collection = fetch_analysis_data(company_id)
      result = collection.select { |item| item[0] == "所在地" }
      result[0][1] if result.size > 0
    end

    def fetch_webpage_url_by_company_id(company_id)
      collection = fetch_analysis_data(company_id)
      result = collection.select { |item| item[0] == "URL" }
      result[0][1] if result.size > 0
    end

    def fetch_analysis_data(company_id)
      analysis_collection ||= Doc::Analysis.new(company_id).collect
    end
  end
end
