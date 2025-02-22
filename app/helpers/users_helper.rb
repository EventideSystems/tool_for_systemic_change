# frozen_string_literal: true

# Helper methods for the Users.
module UsersHelper
  BADGE_BASE_CLASS = 'inline-flex items-center gap-x-1.5 rounded-md px-1.5 py-0.5 text-sm/5 font-medium sm:text-xs/5 forced-colors:outline text-black' # rubocop:disable Layout/LineLength

  def role_in_current_account_badge(user)
    account_role = role_in_current_account(user)
    return '' if account_role.blank?

    badge_class = role_in_current_account_badge_class(account_role)
    member_since = AccountsUser.find_by(user: user, account: current_account).created_at.strftime('%b. %Y')

    content_tag(:span, "Account #{account_role.titleize}", class: badge_class, title: "Member since #{member_since}")
  end

  def user_system_role_badge(user)
    return '' if user.blank?

    badge_class = user_system_role_badge_class(user.system_role)
    member_since = user.created_at.strftime('%b. %Y')

    content_tag(:span, "System #{user.system_role.titleize}", class: badge_class, title: "Member since #{member_since}")
  end

  def user_status_badge(user)
    return '' if user.blank? || user.status == 'active'

    badge_class = user_status_badge_class(user.status)

    content_tag(:span, user.status.titleize, class: badge_class)
  end

  def options_for_timezone_select
    ActiveSupport::TimeZone.all.map do |tz|
      ["#{tz.tzinfo} [#{tz.formatted_offset}]", tz.name]
    end
  end

  def display_time_zone(time_zone)
    return '' if time_zone.blank?

    "#{time_zone} #{ActiveSupport::TimeZone[time_zone].formatted_offset}"
  end

  private

  def role_in_current_account_badge_class(account_role)
    case account_role.to_sym
    when :admin
      "#{BADGE_BASE_CLASS} bg-pink-400"
    when :member
      "#{BADGE_BASE_CLASS} bg-lime-400"
    end
  end

  def role_in_current_account(user)
    accounts_user = AccountsUser.where(user: user, account: current_account).first
    accounts_user.try(:account_role)
  end

  def user_system_role_badge_class(system_role)
    case system_role.to_sym
    when :admin
      "#{BADGE_BASE_CLASS} bg-yellow-400"
    when :member
      "#{BADGE_BASE_CLASS} bg-green-400"
    end
  end

  def user_status_badge_class(status)
    case status.to_sym
    when :deleted
      "#{BADGE_BASE_CLASS} bg-red-400"
    when :'invitation-pending'
      "#{BADGE_BASE_CLASS} bg-blue-400"
    end
  end
end
