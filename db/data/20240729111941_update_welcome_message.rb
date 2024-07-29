# frozen_string_literal: true

class UpdateWelcomeMessage < ActiveRecord::Migration[7.0]
  def up
    Account.find_each do |account|
      account.update_column(:welcome_message, new_welcome_message(account.welcome_message))
    end
  end

  def down
    Account.find_each do |account|
      account.update_column(:welcome_message, old_welcome_message(account.welcome_message))
    end
  end

  private

  def new_welcome_message(original_message)
    original_message.gsub(
      "Welcome to Wicked Lab's Tool for Systemic Change",
      'Welcome to the Tool for Systemic Change'
    ).gsub(
      'support@wickedlab.com.au',
      'hello@toolforsystemicchange.com'
    )
  end

  def old_welcome_message(_new_message)
    original_message.gsub(
      "Welcome to Wicked Lab's Tool for Systemic Change",
      'Welcome to the Tool for Systemic Change'
    ).gsub(
      'support@wickedlab.com.au',
      'hello@toolforsystemicchange.com'
    )
  end
end
