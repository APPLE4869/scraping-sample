# coding: utf-8
require 'uri'
require 'faraday'
require 'nokogiri'
require 'redis'

class Scraping
  CACHE_TTL = 3600
  URL_REGEXP = /\A#{URI::regexp(%w(http https))}\z/

  def initialize(base_url)
    raise ArgumentError unless base_url =~ URL_REGEXP
    @base_url = base_url
  end

  # @return Nokogiri::HTML::Document
  def fetch_doc(path)
    raise ArgumentError unless path.kind_of?(String)

    cache_key = @base_url + path
    html = redis_client.get(cache_key)

    if html == nil
      # スクレイピングによる連続アクセスを防ぐために、通信ごとにsleep timeを設けている。
      p "Sleeping..."
      sleep(rand(1..3))
      p "Wake Up!"
      connection = Faraday.new(@base_url)
      response = connection.get(path, { headers: { "User-Agent": Ua.gen } })
      html = response.body

      redis_client.set(cache_key, html)
      redis_client.expire(cache_key, CACHE_TTL)
    end

    nokogiri_doc_by_html(html)
  end

  private

  def redis_client
    @redis_client ||= Redis.new(host: "127.0.0.1", port: 6379)
  end

  def nokogiri_doc_by_html(html)
    raise ArgumentError unless html.kind_of?(String)
    Nokogiri::HTML.parse(html, nil, "utf-8")
  end
end
