# frozen_string_literal: true

# Controller for goals (aka focus areas)
# This controller is a similar to the IndicatorsController, just at a different nesting level in the data model.
class GoalsController < ApplicationController
  include DataModelSupport

  def show
    @goal = FocusAreaGroup.find(params[:id])
    authorize @goal
  end

  def edit
    @goal = FocusAreaGroup.find(params[:id])
    authorize @goal
  end

  def update # rubocop:disable Metrics/MethodLength
    @goal = FocusAreaGroup.find(params[:id])
    authorize @goal

    @goal.assign_attributes(goal_params)

    if @goal.save
      respond_to do |format|
        format.html { redirect_to impact_card_data_model_path(@goal) }
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def goal_params
    params.require(:focus_area_group).permit(DATA_MODEL_ELEMENT_PARAMS).tap do |whitelisted|
      whitelisted.delete(:code) if whitelisted[:code].blank?
    end
  end
end
