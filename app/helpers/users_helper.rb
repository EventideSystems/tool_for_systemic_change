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

  # inline-flex items-center gap-x-1.5 rounded-md px-1.5 py-0.5 text-sm/5 font-medium sm:text-xs/5 forced-colors:outline bg-pink-400/15 text-pink-700 group-data-[hover]:bg-pink-400/25 dark:bg-pink-400/10 dark:text-pink-400 dark:group-data-[hover]:bg-pink-400/20
  # inline-flex items-center gap-x-1.5 rounded-md px-1.5 py-0.5 text-sm/5 font-medium sm:text-xs/5 forced-colors:outline bg-lime-400/20 text-lime-700 group-data-[hover]:bg-lime-400/30 dark:bg-lime-400/10 dark:text-lime-300 dark:group-data-[hover]:bg-lime-400/15

  def role_in_current_account_badge(user)
    role = role_in_current_account(user)
    return '' if role.blank?

    base_class = 'inline-flex items-center gap-x-1.5 rounded-md px-1.5 py-0.5 text-sm/5 font-medium sm:text-xs/5 forced-colors:outline'

    case role.to_sym
    when :admin
      base_class += ' bg-pink-400 text-black'
    when :member
      base_class += ' bg-lime-400 text-black'
    end

    content_tag(:span, role, class: base_class, title: "Member since #{user.created_at.strftime('%b. %Y')}")
  end

  def role_in_current_account(user)
    accounts_user = AccountsUser.where(user: user, account: current_account).first
    accounts_user.try(:account_role)
  end

  def options_for_timezone_select
    ActiveSupport::TimeZone.all.map do |tz|
      ["#{tz.tzinfo} [#{tz.formatted_offset}]", tz.name]
    end
  end
end
