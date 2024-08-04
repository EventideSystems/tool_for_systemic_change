# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts_users
#
#  id           :integer          not null, primary key
#  account_role :integer          default("member")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :integer
#  user_id      :integer
#
# Indexes
#
#  index_accounts_users_on_account_id              (account_id)
#  index_accounts_users_on_account_id_and_user_id  (account_id,user_id) UNIQUE
#  index_accounts_users_on_user_id                 (user_id)
#
class AccountsUser < ApplicationRecord
  enum account_role: { member: 0, admin: 1 }

  belongs_to :user
  belongs_to :account

  delegate :name, to: :account, prefix: true, allow_nil: true
end
