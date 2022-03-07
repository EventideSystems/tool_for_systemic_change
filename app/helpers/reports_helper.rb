# frozen_string_literal: true

module ReportsHelper
  def options_for_comment_statuses
    ChecklistItemComment.statuses.keys.map { |status| [status.titleize, status] }
  end

  def activity_report_name
    return 'Activity Report' if current_account.scorecard_types.count > 1

    "#{current_account.scorecard_types.first.model_name.human} Activity Report"
  end

  def comments_report_name
    return 'Comments Report' if current_account.scorecard_types.count > 1

    "#{current_account.scorecard_types.first.model_name.human} Comments Report"
  end

  def stakeholder_report_name
    return 'Stakeholder Report' if current_account.scorecard_types.count > 1

    "#{current_account.scorecard_types.first.model_name.human} Stakeholder Report"
  end

  def report_scorecard_label
    return 'Select card' if current_account.scorecard_types.count > 1

    current_account.scorecard_types.first.model_name.human
  end
end
