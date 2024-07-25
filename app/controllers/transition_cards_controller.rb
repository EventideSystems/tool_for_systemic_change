class TransitionCardsController < ScorecardsController
  add_breadcrumb TransitionCard.model_name.human.pluralize, :transition_cards_path

  def index
    @scorecards = policy_scope(Scorecard).where(type: 'TransitionCard').order(sort_order).page(params[:page])
  end

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
