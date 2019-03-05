# coding: utf-8
require 'uri'
require 'faraday'
require 'nokogiri'

class Scraping
  URL_REGEXP = /\A#{URI::regexp(%w(http https))}\z/

  def initialize(base_url)
    raise ArgumentError unless base_url =~ URL_REGEXP
    @base_url = base_url
  end

  # @return Nokogiri::HTML::Document
  def fetch_doc(path)
    raise ArgumentError unless path.kind_of?(String)

    # スクレイピングによる連続アクセスを防ぐために、通信ごとにsleep timeを設けている。
    p "Sleeping..."
    sleep(rand(1..3))
    p "Wake Up!"
    connection = Faraday.new(@base_url)
    response = connection.get(path)

    nokogiri_doc_by_html(response.body)
  end

  private

  def nokogiri_doc_by_html(html)
    raise ArgumentError unless html.kind_of?(String)
    Nokogiri::HTML.parse(html, nil, "utf-8")
  end
end
