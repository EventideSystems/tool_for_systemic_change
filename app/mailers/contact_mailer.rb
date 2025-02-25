# frozen_string_literal: true

# Mailer for contact requests.
class ContactMailer < ApplicationMailer
  def contact(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(subject: 'Contact request', to: 'tom@eventidesystems.com')
  end
end
