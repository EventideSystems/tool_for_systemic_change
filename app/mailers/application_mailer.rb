# frozen_string_literal: true

# Base class for all mailers in the application.
class ApplicationMailer < ActionMailer::Base
  default from: 'hello@toolforsystemicchange.com'
  layout 'mailer'
end
