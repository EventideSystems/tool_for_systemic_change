# frozen_string_literal: true

namespace :accounts do
  desc 'Update account expiry warnings'
  task update_expiry_warnings: :environment do
    AccountExpiryWarningNotifier.call
  end
end
