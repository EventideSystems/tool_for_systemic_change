# frozen_string_literal: true

# Helper methods for the Users.
module UsersHelper
  def role_in_current_account_badge(user)
    role = role_in_current_account(user)
    return '' if role.blank?

    # rubocop:disable Layout/LineLength
    base_class = 'inline-flex items-center gap-x-1.5 rounded-md px-1.5 py-0.5 text-sm/5 font-medium sm:text-xs/5 forced-colors:outline text-black'
    # rubocop:enable Layout/LineLength
    case role.to_sym
    when :admin
      base_class += ' bg-pink-400'
    when :member
      base_class += ' bg-lime-400'
    end

    content_tag(:span, role, class: base_class, title: "Member since #{user.created_at.strftime('%b. %Y')}")
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
