module Vorkers
  module Doc
    class Review
      def initialize(company_id)
        raise ArgumentError unless company_id.kind_of?(String)
        @company_id = company_id
      end

      def collect
        []
      end

      private

      def scraping_client
        @scraping_client ||= Scraping.new(BASE_URL, Auth.new)
      end

      def path
        URI.escape("/#{@company_id}/analysis/")
      end
    end
  end
end
