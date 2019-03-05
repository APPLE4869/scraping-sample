# coding: utf-8
require 'faraday'
require 'nokogiri'

class Vorkers
  BASE_URL = "https://www.vorkers.com"

  def initialize(company_name)
    raise ArgumentError unless company_name.kind_of?(String)
    @company_name = company_name
  end

  # 企業情報を取得
  def fetch_corporate_info
    fetch_info = {}
    fetch_company_id_list.each do |company_id|
      fetch_info[company_id] = fetch_company_analysis_info(company_id) + fetch_company_ranking_endpoint(company_id)
    end
    fetch_info
  end

  # レビュー情報を取得
  def fetch_reviews
  end

  # 求人情報を取得
  def fetch_recruit_info
  end

  # その他の情報を取得
  def fetch_others
  end

  private

  # Vorkersの企業IDを取得
  def fetch_company_id_list
    return @company_id_list if @company_id_list

    response = Faraday.get(company_list_endpoint)
    p response.status
    p response.headers
    p response.body
    list_doc = nokogiri_doc_by_html(response.body)

    @company_id_list = []
    list_doc.xpath('//div[@class="searchCompanyName"]').each do |node|
      href = node.css('a').attribute('href').value
      m = href.match(/.+?m_id=([A-Za-z0-9]+)/)
      @company_id_list << m[1]
    end

    @company_id_list
  end

  def fetch_company_analysis_info(company_id)
    response = Faraday.get(company_analysis_endpoint(company_id))
    analysis_doc = nokogiri_doc_by_html(response.body)

    dt_elms = []
    dd_elms = []
    analysis_doc.xpath('//dl[@class="definitionList-table mt-15"]').each do |node|
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

  def fetch_company_ranking_endpoint(company_id)
    response = Faraday.get(company_ranking_endpoint(company_id))
    ranking_doc = nokogiri_doc_by_html(response.body)

    ranks = []
    ranking_doc.css('#tab1').xpath('.//article[contains(@class, "article")]').each do |node|
      ranks << [
        node.at_xpath('.//span[@class="colonListTerm fw-n"]').text,
        node.at_xpath('.//span[@class="rankingBar_balloon-inner"]').text
      ]
    end
    ranks
  end

  def nokogiri_doc_by_html(html)
    raise ArgumentError unless html.kind_of?(String)
    Nokogiri::HTML.parse(html, nil, "utf-8")
  end

  def company_list_endpoint
    URI.escape("#{BASE_URL}/company_list?field=&pref=&src_str=#{@company_name}&sort=1&ct=comlist")
  end

  def company_analysis_endpoint(company_id)
    URI.escape("#{BASE_URL}/#{company_id}/analysis/")
  end

  def company_ranking_endpoint(company_id)
    URI.escape("#{BASE_URL}/#{company_id}/ranking/")
  end
end
