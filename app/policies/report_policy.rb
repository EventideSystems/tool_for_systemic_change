# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  def index?
    true
  end

  def initiatives_report?
    true
  end

  def initiatives_results?
    true
  end

  def stakeholders_report?
    true
  end

  def stakeholders_results?
    true
  end

  def transition_card_activity?
    true
  end

  def cross_account_percent_actual?
    user_has_active_accounts_with_admin_role?
  end

  def cross_account_percent_actual_by_focus_area?
    user_has_active_accounts_with_admin_role?
  end

  def cross_account_percent_actual_by_focus_area_tabbed?
    user_has_active_accounts_with_admin_role?
  end

  def subsystem_summary?
    system_admin? || account_admin?(current_account)
  end

  private

  def user_has_active_accounts_with_admin_role?
    user_context.user.active_accounts_with_admin_role.exists?
  end
end
