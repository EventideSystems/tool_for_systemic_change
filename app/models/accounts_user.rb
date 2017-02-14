class AccountsUser < ApplicationRecord
  belongs_to :user
  belongs_to :account
  
  enum account_role: [ :regular, :admin ]
end
