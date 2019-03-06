module Vorkers
  module Doc
    class Recruit
      def initialize(company_id)
        raise ArgumentError unless company_id.kind_of?(String)
        @company_id = company_id
      end

      def collect
        collection = {}
        detail_url_suffixes = fetch_detail_url_suffixes

        detail_url_suffixes.each do |detail_url_suffix|
          collection[detail_url_suffix] = fetch_recruit_detail_info(detail_url_suffix)
        end

        collection
      end

      private

      def scraping_client
        @scraping_client ||= Scraping.new(BASE_URL, Auth.new)
      end

      def recruit_list_path
        URI.escape("/#{@company_id}/job/")
      end

      def recruit_detail_path(detail_url_suffix)
        URI.escape("/#{@company_id}/#{detail_url_suffix}")
      end

      def fetch_detail_url_suffixes
        doc = scraping_client.fetch_doc(recruit_list_path)

        if doc.css('#mainContents').count == 1
          pattern1_detail_url_suffix_info(doc)
        elsif doc.css('#mainColumn').count == 1
          pattern2_detail_url_suffix_info(doc)
        else
          raise
        end
      end

      def fetch_recruit_detail_info(detail_url_suffix)
        doc = scraping_client.fetch_doc(recruit_detail_path(detail_url_suffix))

        if doc.css('#mainContents').count == 1
          pattern1_detail_info(doc)
        elsif doc.css('#mainColumn').count == 1
          pattern2_detail_info(doc)
        else
          raise
        end
      end

      def pattern1_detail_url_suffix_info(doc)
        recruit_detail_url_suffix_list = []
        doc.css('#mainContents').xpath('.//article[contains(@class, "article-wide")]').each do |node|
          href = node.css("h2").at_xpath('.//a').attribute('href').value
          m = href.match(/\/#{@company_id}\/(recruit_[a-z]+\?j=[A-Za-z0-9]+)/)
          recruit_detail_url_suffix_list << m[1]
        end
        recruit_detail_url_suffix_list
      end

      def pattern2_detail_url_suffix_info(doc)
        recruit_detail_url_suffix_list = []
        doc.css('#mainColumn').xpath('.//article[contains(@class, "break-word")]').each do |node|
          href = node.at_xpath('.//a[contains(@class, "button-usuallyBlue")]').attribute('href').value
          m = href.match(/\/#{@company_id}\/(recruit_[a-z]+\?j=[A-Za-z0-9]+)/)
          recruit_detail_url_suffix_list << m[1]
        end
        recruit_detail_url_suffix_list
      end

      def pattern1_detail_info(doc)
        data = []
        top_node = doc.css('#mainContents')
        data << ["タイトル", top_node.at_xpath('.//div[contains(@class, "article_head-jobDetail")]')&.at_xpath('.//h2')&.text]

        dt_texts = []
        dd_texts = []
        dl_node = top_node.at_xpath('.//div[@class="article_job"]')&.at_xpath('.//dl')
        return [] if dl_node == nil
        dl_node.xpath('.//dt').each do |node|
          dt_texts << node.text
        end
        dl_node.xpath('.//dd').each do |node|
          dd_texts << node.text
        end
        dt_texts.each_with_index do |dt_text, i|
          data << [dt_text, dd_texts[i]]
        end

        updated_at_text = top_node.at_xpath('.//div[@class="article_job"]').at_xpath('.//p[@class="t-r mt-30 gray"]').at_xpath('.//span[@class="colonListTerm"]')&.text
        m_updated_at = updated_at_text&.match(/\d{4}年\d{2}月\d{2}日/)
        updated_at = m_updated_at ? m_updated_at[0] : nil
        data << ["最終更新日", updated_at]
        data
      end

      def pattern2_detail_info(doc)
        data = []
        top_node = doc.css('#mainColumn')
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
