# frozen_string_literal: true
class AccountsUser < ApplicationRecord
  enum account_role: { member: 0, admin: 1 }

  belongs_to :user
  belongs_to :account
  
  def to_label
    
    # account.try(:name)
    'Foo'
  end
  
  def account_name
    account.try(:name)
  end
end
