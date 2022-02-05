# frozen_string_literal: true

ActionMailer::Base.smtp_settings = {
  address: 'smtp.mandrillapp.com',
  port: 587,
  user_name: ENV['MANDRILL_USERNAME'],
  password: ENV['MANDRILL_API_KEY'],
  domain: 'wickedlab.com.au'
}
ActionMailer::Base.delivery_method = :smtp

MandrillMailer.configure do |config|
  config.api_key = ENV['MANDRILL_API_KEY']
  config.deliver_later_queue_name = :default
end
