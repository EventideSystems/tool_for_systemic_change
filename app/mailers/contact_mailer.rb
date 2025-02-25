# frozen_string_literal: true

# Mailer for contact requests.
class ContactMailer < ApplicationMailer
  def contact(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(subject: 'Contact request', to: contact_mail_recipients)
  end

  private

  def contact_mail_recipients
    ENV['CONTACT_MAIL_RECIPIENTS']
  end
end
