# frozen_string_literal: true

# Holds the user and account context for the current request
class UserContext
  attr_reader :user, :account

  def initialize(user, account)
    @user = user
    @account = account
  end
end
