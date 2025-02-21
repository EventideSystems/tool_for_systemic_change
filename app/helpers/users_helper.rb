# frozen_string_literal: true

# Helper methods for the Users.
module UsersHelper
  BADGE_BASE_CLASS = 'inline-flex items-center gap-x-1.5 rounded-md px-1.5 py-0.5 text-sm/5 font-medium sm:text-xs/5 forced-colors:outline text-black' # rubocop:disable Layout/LineLength

  def role_in_current_account_badge(user)
    role = role_in_current_account(user)
    return '' if role.blank?

    base_class = BADGE_BASE_CLASS.dup
    case role.to_sym
    when :admin
      base_class += ' bg-pink-400'
    when :member
      base_class += ' bg-lime-400'
    end

    member_since = AccountsUser.find_by(user: user, account: current_account).created_at.strftime('%b. %Y')

    content_tag(:span, "Account #{role.titleize}", class: base_class, title: "Member since #{member_since}")
  end

  def user_system_role_badge(user)
    return '' if user.blank?

    base_class = BADGE_BASE_CLASS.dup

    case user.system_role.to_sym
    when :admin
      base_class += ' bg-yellow-400'
    when :member
      base_class += ' bg-green-400'
    end

    member_since = user.created_at.strftime('%b. %Y')

    content_tag(:span, "System #{user.system_role.titleize}", class: base_class, title: "Member since #{member_since}")
  end

  def user_status_badge(user)
    return '' if user.blank? || user.status == 'active'

    base_class = BADGE_BASE_CLASS.dup

    case user.status.to_sym
    when :deleted
      base_class += ' bg-red-400'
    when :'invitation-pending'
      base_class += ' bg-blue-400'
    end

    content_tag(:span, user.status.titleize, class: base_class)
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

  def role_in_current_account(user)
    accounts_user = AccountsUser.where(user: user, account: current_account).first
    accounts_user.try(:account_role)
  end
end
