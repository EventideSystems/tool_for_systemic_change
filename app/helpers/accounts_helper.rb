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
end
