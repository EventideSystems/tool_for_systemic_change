# frozen_string_literal: true

# Helper for Reports
module ReportsHelper
  def options_for_comment_statuses
    ChecklistItemsHelper::CHECKLIST_LIST_ITEM_COLOR_CLASSES.keys.map { |status| [status.to_s.titleize, status] }
  end

  def activity_report_name
    multiple_scorecards_types? ? 'Activity Report' : "#{default_scorecard_type_name} Activity Report"
  end

  def comments_report_name
    multiple_scorecards_types? ? 'Comments Report' : "#{default_scorecard_type_name} Comments Report"
  end

  def stakeholder_report_name
    multiple_scorecards_types? ? 'Stakeholder Report' : "#{default_scorecard_type_name} Stakeholder Report"
  end

  def report_scorecard_label
    multiple_scorecards_types? ? 'Select Card' : default_scorecard_type_name
  end

  private

  def default_scorecard_type_name
    case current_account.scorecard_types.first
    when 'TransitionCard'
      current_account.transition_card_model_name
    when 'SustainableDevelopmentGoalAlignmentCard'
      current_account.sdgs_alignment_card_model_name
    else
      ''
    end
  end

  def multiple_scorecards_types?
    current_account.scorecard_types.count > 1
  end
end
