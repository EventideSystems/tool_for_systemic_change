# frozen_string_literal: true

SidebarPolicy = Struct.new(:user_context, :sidebar) do
  def show_accounts_link?
    system_admin?
  end

  def show_subsystem_tags_link?
    true
  end

  def show_transition_cards?
    return false if user_context.account.blank?

    user_context.account.allow_transition_cards?
  end

  def show_sustainable_development_goal_alignment_cards?
    return false if user_context.account.blank?

    user_context.account.allow_sustainable_development_goal_alignment_cards?
  end

  def show_users_link?
    system_admin? || account_admin?(user_context.account, user_context.user)
  end

  # SMELL Similar code in application_policy
  def account_admin?(account, user)
    return false unless account

    AccountsUser.where(user: user, account: account).first.try(:admin?)
  end

  def system_admin?
    user_context.user.admin?
  end
end
