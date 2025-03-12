# frozen_string_literal: true

class OrganisationPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      resolve_to_current_account
    end
  end

  def show?
    system_admin? || account_admin?(record.account) || account_member?(record.account)
  end

  def create?
    system_admin? || (current_account_admin? && current_account_not_expired?)
  end

  def update?
    system_admin? || (account_admin?(record.account) && current_account_not_expired?)
  end

  def destroy?
    system_admin? || account_admin?(record.account)
  end
end
