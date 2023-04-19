# frozen_string_literal: true

class AccountMailer < ApplicationMailer
  def expiry_warning(account, user)
    user_name = user.name.presence || 'Wicked Lab User'
    expires_on = account.expires_on&.strftime('%B %d, %Y').presence || 'sometime in the future'

    send_mail(
      subject: 'Your account is about to expire',
      to: user.email,
      content: render_template('expiry_warning', user_name: user_name, expires_on: expires_on)
    )
  end
end
