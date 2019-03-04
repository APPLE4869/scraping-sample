
    
# coding: UTF-8
import os
import urllib.request, urllib.error
from bs4 import BeautifulSoup
import re

class Vorkers:
    def fetch_company_ids(self, company_name):
        url = "https://www.vorkers.com/company_list?field=&pref=&src_str=" + self.convert_quote(company_name) + "&sort=1&ct=comlist"

        soup = self.__make_soup(url)

        ids = []
        company_list = soup.find_all(attrs={"class": "searchCompanyName"})
        for company in company_list:
            href = company.a.get('href')
            match = re.search(r'.+?m_id=([A-Za-z0-9]+)', href)
            ids.append(match.group(1))

        return ids

    def fetch_company_by_id(self, company_id):
        # アクセスするURL
        url = "https://www.vorkers.com/company.php?m_id=" + company_id

        soup = self.__make_soup(url)

        result = dict()

        title = soup.title.string
        contents_header = soup.find(attrs={"id": "contentsHeader_text"})
        rate = contents_header.find("p", attrs={"class": "contentsHeader_rating"}).string
        review_count = contents_header.find("span", attrs={"class": "pcIcon pcIcon-48 pcIcon-contentsHeader"})
        reviews = list(map(lambda dd: dd.text, soup.find_all(attrs={"class": "article_answer"})))

        result.update({
            'title': title,
            'rate': rate,
            'review_count': review_count,
            'reviews': reviews
        })

        return result

    def convert_quote(self, string):
        return  urllib.parse.quote_plus(string, encoding='utf-8')

    def __make_soup(self, url):
        # URLにアクセスする htmlが帰ってくる → <html><head><title>経済、株価、ビジネス、政治のニュース:日経電子版</title></head><body....
        ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.109 Safari/537.36'
        if 'USERAGENTIDENTIFIER_API_KEY' in os.environ:
            url += '&api_key=' + os.environ['USERAGENTIDENTIFIER_API_KEY'] + '&user_agent=' + ua
        print("--------------")
        print(ua)
        print(url)
        headers = {
            'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'user-agent': ua
        }
        req = urllib.request.Request(url , headers=headers)
        html = urllib.request.urlopen(req).read()

        # htmlをBeautifulSoupで扱う
        soup = BeautifulSoup(html, "html.parser")
        return soup