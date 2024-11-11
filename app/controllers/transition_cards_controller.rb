# frozen_string_literal: true

class TransitionCardsController < ScorecardsController
  sidebar_item :impact_cards

  def scorecard_key_param
    :transition_card
  end

  def scorecard_class_name
    'TransitionCard'
  end
end
