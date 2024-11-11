# frozen_string_literal: true

class UserContext
  attr_reader :user, :account

  def initialize(user, account)
    @user = user
    @account = account
  end
end
