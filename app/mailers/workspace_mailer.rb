# frozen_string_literal: true

# Mailer for workspace-related notifications.
class WorkspaceMailer < ApplicationMailer
  def expiry_warning(workspace, user)
    @user_name = user.name.presence || 'Tool for Systemic Change User'
    @expires_on = workspace.expires_on&.strftime('%B %d, %Y').presence || 'sometime in the future'
    @pricing_pdf = 'Pricing.Summary_TC.+.SDG.pdf'
    mail(subject: 'Your workspace is about to expire', to: user.email)
  end
end
