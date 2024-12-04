# frozen_string_literal: true

# Controller for managing transition cards - to be deprecated in favour of ImpactCardsController
class TransitionCardsController < ImpactCardsController
  sidebar_item :impact_cards

  def scorecard_key_param
    :transition_card
  end

  def scorecard_class_name
    'TransitionCard'
  end
end
