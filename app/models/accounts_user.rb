class AccountsUser < ApplicationRecord
  enum account_role: { member: 0, admin: 1 }
  
  belongs_to :user
  belongs_to :account
end
