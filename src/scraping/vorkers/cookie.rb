module Vorkers
  class Cookie
    attr_reader :value

    def initialize(cookie_string)
      raise ArgumentError unless cookie_string.kind_of?(String)
      @value = cookie_string
    end

    def create_new_cookie_by_response(response)
      raise ArgumentError unless response.kind_of?(Faraday::Response)

      current_cookie_hash = gen_cookie_hash(@value)
      set_cookie_hash = gen_cookie_hash(response.headers["set-cookie"])
    
      cookie_string =  gen_cookie_string(
        v_clid:         set_cookie_hash[:v_clid] || current_cookie_hash[:v_clid],
        phpsessionid:   set_cookie_hash[:phpsessionid] || current_cookie_hash[:phpsessionid],
        hashed_user_id: set_cookie_hash[:hashed_user_id] || current_cookie_hash[:hashed_user_id],
        awsalb:         set_cookie_hash[:awsalb] || current_cookie_hash[:awsalb]
      )
      Cookie.new(cookie_string)
    end

    private

    def gen_cookie_hash(cookie_string)
      {
        v_clid: match_value(cookie_string, "v_clid"),
        phpsessionid: match_value(cookie_string, "PHPSESSID"),
        hashed_user_id: match_value(cookie_string, "hashed_user_id"),
        awsalb: match_value(cookie_string, "AWSALB")
      }
    end

    def match_value(cookie_string, cookie_key)
      regex =
        case cookie_key
        when "v_clid" then
          /.*v_clid=([a-z0-9-]+).*/
        when "PHPSESSID" then
          /.*PHPSESSID=([a-z0-9]+)*/
        when "hashed_user_id" then
          /.*hashed_user_id=([a-z0-9\-]+).*/
        when "AWSALB" then
          /.*AWSALB=([A-Za-z0-9+\/]+).*/
        else
          raise ArgumentError
        end

      m = cookie_string.match(regex)
      m[1] if m
    end

    def gen_cookie_string(v_clid:, phpsessionid:, hashed_user_id:, awsalb:)
      "v_clid=#{v_clid}; PHPSESSID=#{phpsessionid}; hashed_user_id=#{hashed_user_id}; AWSALB=#{awsalb};"
    end
  end
end
