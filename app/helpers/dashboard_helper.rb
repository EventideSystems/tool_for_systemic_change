# frozen_string_literal: true

module DashboardHelper

  def content_title
    content_tag(:h1) do
      concat(controller.content_title)
      concat(content_tag(:small, controller.content_subtitle))
      concat(yield) if block_given?
    end
  end

  def default_scorecards_path
    return '' if current_account.blank?

    case current_account.scorecard_types.first.name
    when 'TransitionCard'
      transition_cards_path
    when 'SustainableDevelopmentGoalAlignmentCard'
      sustainable_development_goal_alignment_cards_path
    else
      raise('Unknown scorecard type')
    end
  end
end
