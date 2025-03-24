# frozen_string_literal: true

# NOTE: This is **not** a nested resource, but a separate controller that is used to create
# wicked problem (aka 'opportunity') records within the context of impact cards.
class ImpactCardsWickedProblemsController < ApplicationController
  def index; end

  def new
    @wicked_problem = current_workspace.wicked_problems.new
    authorize @wicked_problem
  end

  def create # rubocop:disable Metrics/MethodLength
    @wicked_problem = current_workspace.wicked_problems.new(wicked_problem_params)
    authorize @wicked_problem

    if @wicked_problem.save
      respond_to do |format|
        format.html
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            'new_impact_cards_wicked_problems_form',
            partial: 'form',
            locals: { label: @wicked_problem }
          )
        end
      end
    end
  end

  private

  def wicked_problem_params
    params.require(:wicked_problem).permit(:name, :color)
  end
end
