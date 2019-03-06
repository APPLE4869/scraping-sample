module Vorkers
  module Doc
    class Analysis
      def initialize(company_id)
        raise ArgumentError unless company_id.kind_of?(String)
        @company_id = company_id
      end

      def collect
        doc = scraping_client.fetch_doc(path)

        if doc.css('#mainContents').count == 1
          pattern1_info(doc)
        elsif doc.css('#mainColumn').count == 1
          pattern2_info(doc)
        else
          raise
        end
      end

      private

      def pattern1_info(doc)
        dt_elms = []
        dd_elms = []
        doc.css('#mainContents').xpath('.//dl[contains(@class,"borderList") or contains(@class,"plainList")]').each do |node|
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

      def pattern2_info(doc)
        dt_elms = []
        dd_elms = []
        doc.css('#mainColumn').xpath('.//dl[contains(@class,"definitionList-table")]').each do |node|
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

      def scraping_client
        @scraping_client ||= Scraping.new(BASE_URL, Auth.new)
      end

      def path
        URI.escape("/#{@company_id}/analysis/")
      end
    end
  end
end
