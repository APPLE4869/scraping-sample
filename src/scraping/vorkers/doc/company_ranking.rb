module Vorkers
  module Doc
    class CompanyRanking 
      def initialize(company_id)
        raise ArgumentError unless company_id.kind_of?(String)
        @company_id = company_id
      end

      def collect
        doc = scraping_client.fetch_doc(path)

        ranks = []
        doc.css('#tab1').xpath('.//article[contains(@class, "article")]').each do |node|
          ranks << [
            node.at_xpath('.//span[contains(@class, "colonListTerm")]')&.text,
            node.at_xpath('.//span[@class="rankingBar_balloon-inner"]')&.text
          ]
        end
        ranks
      end

      private

      def scraping_client
        @scraping_client ||= Scraping.new(BASE_URL, Auth.new)
      end

      def path
        URI.escape("/#{@company_id}/ranking/")
      end
    end
  end
end
