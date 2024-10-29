# frozen_string_literal: true

class TransitionCardsController < ScorecardsController
  sidebar_item :impact_cards

  # def index
  #   @scorecards = policy_scope(Scorecard).where(type: 'TransitionCard').order(sort_order).page(params[:page])
  # end

  def content_title
    current_account.transition_card_model_name.pluralize
  end

  def scorecard_key_param
    :transition_card
  end

  def scorecard_class_name
    'TransitionCard'
  end

end
