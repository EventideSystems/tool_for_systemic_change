# frozen_string_literal: true

class AccountMailer < ApplicationMailer
  def expiry_warning(account, user)
    @user_name = user.name.presence || 'Wicked Lab User'
    @expires_on = account.expires_on&.strftime('%B %d, %Y').presence || 'sometime in the future'
    @pricing_pdf = 'Pricing.Summary_TC.+.SDG.pdf'
    mail(
      subject: 'Your account is about to expire',
      to: user.email
    )
  end
end
