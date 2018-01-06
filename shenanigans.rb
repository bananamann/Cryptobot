require 'net/smtp'

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
  smtp.start(opts[:server], "cryptobotv1@gmail.com", "hellomynameispierce", :login) do
    smtp.send_message(msg, opts[:from], to)
  end
end

test_send_email "6149050800@tmomail.net", :subject => "Placeholder", :body => "APPARENTLY IT NEEDS A FROM"
