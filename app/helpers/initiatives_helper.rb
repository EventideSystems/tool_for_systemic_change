# frozen_string_literal: true

# Helper methods for presenting initiative data
module InitiativesHelper
  def mail_to_contact_email(initiative)
    return '' if initiative&.contact_email.blank?

    mail_to(
      initiative.contact_email,
      initiative.contact_email,
      class: 'text-blue-500 hover:text-blue-700 underline'
    )
  end
end
