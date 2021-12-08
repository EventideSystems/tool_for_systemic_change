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
end
