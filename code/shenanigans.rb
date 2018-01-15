require 'net/smtp'
require 'net/http'
require 'net/https'
require 'base64'
require 'json'

def test_send_email(to,opts={})
  opts[:server]      ||= 'localhost'
  opts[:from]        ||= 'email@example.com'
  opts[:from_alias]  ||= 'Example Emailer'
  opts[:subject]     ||= "You need to see this"
  opts[:body]        ||= "Important stuff!"

  msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

  #{opts[:body]}
END_OF_MESSAGE

  smtp = Net::SMTP.new 'smtp.gmail.com', 587
  smtp.enable_starttls
  smtp.start(opts[:server], "cryptobotv1@gmail.com", Base64.decode64("aGVsbG9teW5hbWVpc3BpZXJjZQ==\n"), :login) do
    smtp.send_message(msg, opts[:from], to)
  end
end

def test_get_trade_data
  uri = URI.parse "https://www.cryptopia.co.nz/api/GetMarkets/BTC"
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  response = JSON.parse(http.request(req).body)

  puts response
end

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# RUN TEST METHODS BELOW
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

test_get_trade_data

# test_send_email "6149050800@tmomail.net", :subject => "Placeholder", :body => "APPARENTLY IT NEEDS A FROM"
