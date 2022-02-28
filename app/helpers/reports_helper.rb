# frozen_string_literal: true

module ReportsHelper
  def options_for_comment_statuses
    ChecklistItemComment.statuses.keys.map { |status| [status.titleize, status] }
  end

  def activity_report_name
    return 'Scorecard Activity Report' if current_account.scorecard_types.count > 1

    "#{current_account.scorecard_types.first.model_name.human} Activity Report"
  end

  def comments_report_name
    return 'Scorecard Comments Report' if current_account.scorecard_types.count > 1

    "#{current_account.scorecard_types.first.model_name.human} Comments Report"
  end

  def stakeholder_report_name
    return 'Scorecard Stakeholder Report' if current_account.scorecard_types.count > 1

    "#{current_account.scorecard_types.first.model_name.human} Stakeholder Report"
  end

  def scorecard_label
    return 'Scorecard' if current_account.scorecard_types.count > 1

    current_account.scorecard_types.first.model_name.human
  end
end
