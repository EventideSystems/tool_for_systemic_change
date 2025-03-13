# frozen_string_literal: true

class UserPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      if account_admin?(user_context.account) || system_admin?
        base_scope
      else
        base_scope.where(invitation_token: nil)
      end
    end

    def base_scope
      scope.joins(:accounts_users).where('accounts_users.account_id' => current_account.id)
    end
  end

  def show?
    system_admin? || current_account_any_role?
  end

  def create?
    system_admin? || (current_account_any_role? && current_account_not_expired?)
  end

  def invite?
    create?
  end

  def invite_with_system_role?
    invite? && system_admin?
  end

  def update?
    system_admin? || current_account_admin? || record_is_current_user?
  end

  def update_system_role?
    system_admin? && record_is_not_current_user?
  end

  def destroy?
    record_is_not_current_user? && (system_admin? || current_account_admin?)
  end

  def undelete?
    system_admin?
  end

  def resend_invitation?
    system_admin? || current_account_admin?
  end

  def remove_from_account?
    record_is_not_current_user? && (system_admin? || current_account_admin?)
  end

  def max_users_not_reached?(account)
    return false if account.blank?
    return true if account.max_users.zero? # NOTE: magic number, meaning no limit

    account.users.count < account.max_users
  end

  def impersonate?
    system_admin? && record_is_not_current_user?
  end

  def stop_impersonating?
    true
  end

  def change_account_role?
    system_admin? || current_account_admin?
  end

  def change_password?
    system_admin? || record_is_current_user?
  end

  private

  def record_is_current_user?
    user_context.user.id == record.id
  end

  def record_is_not_current_user?
    !record_is_current_user?
  end
end
