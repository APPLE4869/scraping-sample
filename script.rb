require 'redis'
Dir.glob('./src/**/*.rb').each { |file| require file }

# connection = Faraday.new(@base_url)
# response = connection.get(path, { headers: { "User-Agent": Ua.gen } })

email = ENV['VORKERS_EMAIL']
password = ENV['VORKERS_PASSWORD']

auth = Vorkers::Auth.new
auth.login(email: email, password: password)

p auth.authed_cookie_value

response = Faraday.new(Vorkers::BASE_URL).get do |req|
  req.url "/my_top"
  req.headers['User-Agent'] = Ua.gen
  req.headers['Cookie'] = auth.authed_cookie_value
end

p response.status
p response.headers
p response.body[0..550]
