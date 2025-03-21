# frozen_string_literal: true

class ChecklistItemPolicy < ApplicationPolicy # rubocop:disable Style/Documentation
  class Scope < Scope # rubocop:disable Style/Documentation
    def resolve
      scope.joins(initiative: :scorecard).where('scorecards.account_id': current_account.id)
    end
  end

  def show?
    system_admin? || account_any_role?(checklist_item_account)
  end

  def create?
    system_admin? || account_admin?(current_account)
  end

  def create_comment?
    update?
  end

  def update?
    system_admin? || (account_any_role?(checklist_item_account) && current_account_not_expired?)
  end

  # def update_comment?
  #   update?
  # end

  def destroy?
    system_admin? || account_admin?(checklist_item_account)
  end

  private

  def checklist_item_account
    record.initiative.scorecard.account
  end
end
