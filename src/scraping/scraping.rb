# coding: utf-8
require 'uri'
require 'faraday'
require 'nokogiri'
require 'redis'

class Scraping
  CACHE_TTL = 3600 # キャッシュ時間を1時間に設定
  URL_REGEXP = /\A#{URI::regexp(%w(http https))}\z/

  def initialize(base_url, auth)
    raise ArgumentError unless base_url =~ URL_REGEXP
    @base_url = base_url
    @auth = auth
  end

  # @return Nokogiri::HTML::Document
  def fetch_doc(path)
    raise ArgumentError unless path.kind_of?(String)

    cache_key = @base_url + path
    html = redis_client.get(cache_key)

    if html == nil
      # スクレイピングによる連続アクセスでのサーバー負荷を懸念して、通信ごとにSleepTimeを設けている。
      p "Sleeping..."
      sleep(rand(2..4))
      p "Wake Up!"
      response = get_request(path)
      html = response.body

      # TODO (Shokei Takanashi)
      # この場合だと403ページなどでもキャッシュされてしまうので、期待通りのHTMLを取得したケースでのみキャッシュするよう改修する。
      redis_client.set(cache_key, html)
      redis_client.expire(cache_key, CACHE_TTL)
    end

    nokogiri_doc_by_html(html)
  end

  private

  def get_request(path)
    connection = Faraday.new(@base_url)
    response = connection.get do |req|
      req.url path
      req.headers['User-Agent'] = Ua.gen
      req.headers['Cookie'] = @auth.authed_cookie
    end

    @auth.update_authed_cookie(response)

    response
  end

  def redis_client
    @redis_client ||= Redis.new(host: "127.0.0.1", port: 6379)
  end

  def nokogiri_doc_by_html(html)
    raise ArgumentError unless html.kind_of?(String)
    Nokogiri::HTML.parse(html, nil, "utf-8")
  end
end
