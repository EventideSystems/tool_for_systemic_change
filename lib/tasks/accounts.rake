# frozen_string_literal: true

namespace :accounts do
  desc 'Update account expiry warnings'
  task update_expiry_warnings: :environment do
    AccountExpiryWarningNotifier.call
  end

  desc 'List accounts'
  task list: :environment do
    Account.all.each do |account|
      puts "#{account.id}: #{account.name}"
    end
  end

  desc 'Copy account'
  task copy: :environment do
    if ENV['ACCOUNT_NAME'].nil?
      puts 'ACCOUNT_NAME is required'
      exit(1)
    end

    account = Account.find_by(name: ENV.fetch('ACCOUNT_NAME', nil))

    if account.nil?
      puts "Account not found: #{ENV.fetch('ACCOUNT_NAME', nil)}"
      exit(1)
    end

    Accounts::Copy.call(account:, new_name: ENV.fetch('NEW_ACCOUNT_NAME', nil)).tap do |new_account|
      puts "New account created: #{new_account.name}"
    end
  end
end
