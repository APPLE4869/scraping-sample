module Vorkers
  module Doc
    class Review
      REVIEW_TYPES = {
        "1" => "組織体制・企業文化",
        "2" => "年収・給与",
        "3" => "入社理由と入社後のギャップ",
        "4" => "働きがい・成長",
        "5" => "女性の働きやすさ",
        "6" => "ワーク・ライフ・バランス",
        "8" => "退職検討理由",
        "9" => "企業分析[強み・弱み・展望]",
        "10" => "経営者の提言"
      }

      def initialize(company_id)
        raise ArgumentError unless company_id.kind_of?(String)
        @company_id = company_id
      end

      def collect
        collection = {}
        REVIEW_TYPES.each do |review_type_num, review_type_name|
          collection[review_type_num] = {
            name: review_type_name,
            info: fetch_reviews_info(review_type_num)
          }
        end
        collection
      end

      private

      def fetch_reviews_info(review_type_num)
        doc = scraping_client.fetch_doc(review_list_path(review_type_num))

        review_list = []
        doc.css('#mainColumn').xpath('.//article[contains(@class, "article")]').each do |node|
          review_data = []

          detail_node = node.at_xpath('.//div[contains(@class, "article_body")]')
          review_data << ["回答者", detail_node&.css("dt")&.css("a")&.text]
          review_data << ["星の数", detail_node&.css("dt")&.at_xpath('.//span[@class="d-b lh-1o5"]')&.at_xpath('.//span[@class="ml-5 fs-14"]')&.text]
          review_data << ["本文", detail_node&.css("dd")&.text]
          review_data << ["回答日", node&.at_xpath('.//p[@class="article_asideRight"]')&.at_xpath('.//time')&.text]

          review_list << review_data
        end
        review_list
      end

      def scraping_client
        @scraping_client ||= Scraping.new(BASE_URL, Auth.new)
      end

      def review_list_path(review_type_num)
        URI.escape("/company_answer.php?m_id=#{@company_id}&q_no=#{review_type_num}")
      end
    end
  end
end
