module Vorkers
  module Doc
    class Recruit
      def initialize(company_id)
        raise ArgumentError unless company_id.kind_of?(String)
        @company_id = company_id
      end

      def collect
        collection = []
        recruit_ids = fetch_recruit_ids

        recruit_ids.each do |recruit_id|
          collection << fetch_recruit_detail_info(recruit_id)
        end

        collection
      end

      private

      def scraping_client
        @scraping_client ||= Scraping.new(BASE_URL)
      end

      def recruit_list_path
        URI.escape("/#{@company_id}/job/")
      end

      def recruit_detail_path(recruit_id)
        URI.escape("/#{@company_id}/recruit_jam?j=#{recruit_id}")
      end

      def fetch_recruit_ids
        doc = scraping_client.fetch_doc(recruit_list_path)

        recruit_id_list = []
        doc.css('#mainColumn').xpath('.//article[contains(@class, "break-word")]').each do |node|
          href = node.at_xpath('.//a[contains(@class, "button-usuallyBlue")]').attribute('href').value
          m = href.match(/.+?j=([A-Za-z0-9]+)/)
          recruit_id_list << m[1]
        end
        recruit_id_list
      end

      def fetch_recruit_detail_info(recruit_id)
        doc = scraping_client.fetch_doc(recruit_detail_path(recruit_id))

        data = []
        top_node = doc.css('#mainColumn')
        data << ["id", recruit_id]
        data << ["タイトル", top_node.at_xpath('.//h3[contains(@class, "testPreviewJobOfferTitle")]')&.text]

        dt_texts = []
        dd_texts = []
        dl_node = top_node.xpath('.//dl[@class="ml-15 mr-15 mt-n10"]')
        dl_node.xpath('.//dt[contains(@class, "jobTitle-darkBlue")]').each do |node|
          dt_texts << node.text
        end
        dl_node.xpath('.//dd[contains(@class, "lh-high")]').each do |node|
          dd_texts << node.text
        end
        dt_texts.each_with_index do |dt_text, i|
          data << [dt_text, dd_texts[i]]
        end

        updated_at_text = top_node.at_xpath('.//p[contains(@class, "middlegray")]')&.text
        m_updated_at = updated_at_text&.match(/\d{4}年\d{2}月\d{2}日/)
        updated_at = m_updated_at ? m_updated_at[0] : nil
        data << ["最終更新日", updated_at]
        data
      end
    end
  end
end
