# frozen_string_literal: true

class AccountExpiryWarningNotifier
  class << self
    def call
      clear_warnings_for_renewed_accounts
      send_notifications_for_expiring_accounts
    end

    private

    EXPIRY_WARNING_PERIOD = Account::EXPIRY_WARNING_PERIOD

    def send_email(account, user)
      AccountMailer.expiry_warning(account, user).deliver
    end

    def send_notifications_for_expiring_accounts
      Account
        .where(expiry_warning_sent_on: nil)
        .where('expires_on <= ?', EXPIRY_WARNING_PERIOD.from_now)
        .where('expires_on > ?', EXPIRY_WARNING_PERIOD.ago)
        .where('expires_on > ?', Time.zone.today)
        .find_each do |account|
          account.users.find_each do |user|
            send_email(account, user)
          end
          account.update!(expiry_warning_sent_on: Date.current)
        end
    end

    def clear_warnings_for_renewed_accounts
      Account
        .where.not(expiry_warning_sent_on: nil)
        .where.not(expires_on: nil)
        .where('expires_on > ?', EXPIRY_WARNING_PERIOD.from_now)
        .update_all(expiry_warning_sent_on: nil)
    end
  end
end
