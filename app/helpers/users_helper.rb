# frozen_string_literal: true

module UsersHelper
  def current_user_name
    return '' unless user_signed_in?
    current_user.name.presence || current_user.email
  end

  def current_user_membership_summary
    return '' unless user_signed_in?

    "Member since #{current_user.created_at.strftime('%b. %Y')}"
  end

  def user_role_in_current_account(user)
    accounts_user = AccountsUser.where(user: user, account: current_account).first
    accounts_user.try(:account_role)
  end

  def options_for_timezone_select
    ActiveSupport::TimeZone.all.map do |tz|
      ["#{tz.tzinfo} [#{tz.formatted_offset}]", tz.name]
    end
  end
end
