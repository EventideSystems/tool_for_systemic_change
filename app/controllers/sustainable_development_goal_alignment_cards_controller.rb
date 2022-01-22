class SustainableDevelopmentGoalAlignmentCardsController < ScorecardsController

  def index
    @scorecards = policy_scope(Scorecard)
      .where(type: 'SustainableDevelopmentGoalAlignmentCard')
      .order(sort_order).page params[:page]
  end

  def scorecard_class_name
    'SustainableDevelopmentGoalAlignmentCard'
  end

  def content_title
    'SDG Alignment Cards'
  end

  def scorecard_key_param
    :sustainable_development_goal_alignment_card
  end
end
