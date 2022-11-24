# frozen_string_literal: true
class AccountsUser < ApplicationRecord
  enum account_role: { member: 0, admin: 1 }

  belongs_to :user
  belongs_to :account

  delegate :name, to: :account, prefix: true, allow_nil: true
end
