# frozen_string_literal: true

# Helper methods for presenting accounts - soon to be deprecated and replaced with 'workspaces'
module AccountsHelper
  def lookup_accounts
    policy_scope(Account).all
  end

  def lookup_account_roles
    AccountsUser.account_roles.keys
  end

  def lookup_system_roles
    User.system_roles.keys
  end

  def max_users(account)
    "Max users: #{account.max_users.zero? ? 'unlimited' : account.max_users}"
  end

  def max_impact_cards(account)
    "Max impact cards: #{account.max_users.zero? ? 'unlimited' : account.max_scorecards}"
  end

  def expires_on(account)
    return 'Never expires' if account.expires_on.blank?

    "Expires on: #{account.expires_on}"
  end
end
