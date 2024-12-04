# frozen_string_literal: true

class UserPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      if account_admin?(user_context.account) || system_admin?
        scope.joins(:accounts_users).where('accounts_users.account_id' => current_account.id)
      else
        User.none
      end
    end
  end

  class SystemScope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope.with_deleted.all if user_context.user.admin?
    end
  end

  def show?
    system_admin? || account_admin?(user_context.account) || account_member?(user_context.account)
  end

  def create?
    system_admin? || (account_admin?(user_context.account) && max_users_not_reached?(user_context.account))
  end

  def invite?
    create?
  end

  def invite_with_system_role?
    invite? && system_admin?
  end

  def update?
    system_admin? || account_admin?(user_context.account) || record == current_user
  end

  def update_system_role?
    system_admin? && record != current_user
  end

  def destroy?
    return false if user_context.user == record

    system_admin? || account_admin?(user_context.account)
  end

  def undelete?
    system_admin?
  end

  def resend_invitation?
    system_admin? || account_admin?(current_account)
  end

  def remove_from_account?
    return false if user_context.user == record

    system_admin? || account_admin?(user_context.account)
  end

  def max_users_not_reached?(account)
    return false if account.blank?
    return true if account.max_users.zero? # NOTE: magic number, meaning no limit

    account.users.count < account.max_users
  end

  def impersonate?
    system_admin? && !record_is_current_user?
  end

  def stop_impersonating?
    true
  end

  private

  def record_is_current_user?
    user_context.user.id == record.id
  end
end
