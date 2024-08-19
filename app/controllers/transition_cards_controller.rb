# frozen_string_literal: true

class TransitionCardsController < ScorecardsController
  before_action :add_base_breadcrumb

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

  private

  def add_base_breadcrumb
    return '' if current_account.blank?

    # add_breadcrumb(current_account.transition_card_model_name.pluralize, :transition_cards_path)
  end
end
