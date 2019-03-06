# 本クラスはスクレイピング処理を担うScrapingクラスから参照されている。
# 別サイトでも認証用のクラスはAuthと命名し、publicメソッドのInterfaceは揃えること。
module Vorkers
  class Auth
    AUTHED_COOKIE_TTL = 3600 # 1時間
    AUTHED_COOKIE_CACHE_KEY = "VORKERS_AUTHED_COOKIE_CACHE_KEY"

    def initialize
      @authed_cookie = authed_cookie ? Cookie.new(authed_cookie) : nil
    end

    # ログイン処理を実行して、認証されたCookieをキャッシュする。
    def login(email:, password:)
      return if logged_in?

      initial_cookie = Cookie.new("")
      ua = Ua.gen # 認証でのみUAを固定する
      login_page_response = request_login_page(ua)
      p login_page_response.status
      p login_page_response.headers.to_s
      p "----------------------------"
      csrf = fetch_csrf_from_login_page_html(login_page_response.body)
      cookie_for_login = initial_cookie.create_new_cookie_by_response(login_page_response)

      login_action_response = request_login_action(
        email: email,
        password: password,
        cookie: cookie_for_login,
        csrf: csrf,
        ua: ua
      )
      @authed_cookie = cookie_for_login.create_new_cookie_by_response(login_action_response)

      # 以後、ログイン済みのユーザーとしてアクセスする際は、ここでキャッシュしたCookieを利用する。
      redis_client.set(AUTHED_COOKIE_CACHE_KEY, @authed_cookie.value)
      redis_client.expire(AUTHED_COOKIE_CACHE_KEY, AUTHED_COOKIE_TTL)
    end

    def authed_cookie
      redis_client.get(AUTHED_COOKIE_CACHE_KEY)
    end

    def update_authed_cookie(response)
      raise ArgumentError unless response.kind_of?(Faraday::Response)
      return false if authed_cookie.nil?

      @authed_cookie = @authed_cookie.create_new_cookie_by_response(response)
      redis_client.set(AUTHED_COOKIE_CACHE_KEY, @authed_cookie.value)
    end

    def logged_in?
      return false if authed_cookie == nil

      # 認証必須ページを正常に表示できるか確認
      response = connection.get do |req|
        req.url "/mypage"
        req.headers['User-Agent'] = Ua.gen
        req.headers['Cookie'] = authed_cookie
      end

      response.status == 200
    end

    def logout
      redis_client.del(AUTHED_COOKIE_CACHE_KEY)
    end

    private

    def request_login_page(ua)
      connection.get("/login.php", { headers: { "User-Agent": ua } })
    end

    def request_login_action(email:, password:, cookie:, csrf:, ua:)
      connection.post do |req|
        req.url "/login_check"
        req.headers['User-Agent'] = ua
        req.headers['Cookie'] = cookie.value
        req.body = {
          _username: email,
          _password: password,
          _csrf_token: csrf
        }
      end
    end

    def fetch_csrf_from_login_page_html(html)
      doc = Nokogiri::HTML.parse(html, nil, "utf-8")
      doc.at_xpath('//input[@type="hidden"][@name="_csrf_token"]').attribute('value').value
    end

    def connection
      @connection ||= Faraday.new(BASE_URL)
    end

    def redis_client
      redis_url = ENV["REDIS_URL"] || "redis://localhost:6379"
      @redis_client ||= Redis.new(url: redis_url)
    end
  end
end
