module Vorkers
  module Doc
    class Analysis
      def initialize(company_id)
        raise ArgumentError unless company_id.kind_of?(String)
        @company_id = company_id
      end

      def collect
        doc = scraping_client.fetch_doc(path)

        dt_elms = []
        dd_elms = []
        doc.xpath('//dl[@class="definitionList-table mt-15"]').each do |node|
          node.xpath('dt').each do |n_node|
            dt_elms << n_node.text
          end

          node.xpath('dd').each do |n_node|
            dd_elms << n_node.text
          end
        end

        info = []
        dt_elms.each_with_index do |dt_elm, i|
          info << [dt_elm, dd_elms[i]]
        end
        info
      end

      private

      def scraping_client
        @scraping_client ||= Scraping.new(BASE_URL)
      end

      def path
        URI.escape("/#{@company_id}/analysis/")
      end
    end
  end
end
