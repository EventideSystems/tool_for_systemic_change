# frozen_string_literal: true

# Helper for Reports
module ReportsHelper
  def options_for_comment_statuses
    ChecklistItemsHelper::CHECKLIST_LIST_ITEM_COLOR_CLASSES.keys.map { |status| [status.to_s.titleize, status] }
  end

  def activity_report_name
    multiple_scorecards_types? ? 'Activity Report' : "#{default_data_model_name} Activity Report"
  end

  def comments_report_name
    multiple_scorecards_types? ? 'Comments Report' : "#{default_data_model_name} Comments Report"
  end

  def stakeholder_report_name
    multiple_scorecards_types? ? 'Stakeholder Report' : "#{default_data_model_name} Stakeholder Report"
  end

  def report_scorecard_label
    multiple_scorecards_types? ? 'Select Card' : default_data_model_name
  end

  private

  def default_data_model_name
    current_workspace.data_models_in_use&.first&.name.presence || 'Impact Card'
  end

  def multiple_scorecards_types?
    current_workspace.data_models_in_use.count > 1
  end
end
