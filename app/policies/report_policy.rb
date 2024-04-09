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
    user_context.user.accounts_with_admin_role.exists?
  end

  def subsystem_summary?
    system_admin? || account_admin?(current_account)
  end
end
