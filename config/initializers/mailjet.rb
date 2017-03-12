Mailjet.configure do |config|
  config.api_key = ENV['MAILJET_PUBLIC_KEY']
  config.secret_key = ENV['MAILJET_SECRET_KEY']
  # config.default_from = 'my_registered_mailjet_email@domain.com'
end