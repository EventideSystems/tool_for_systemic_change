# frozen_string_literal: true

# Controller for targets (aka focus areas)
# This controller is a similar to the IndicatorsController, just at a different nesting level in the data model.
class TargetsController < ApplicationController
  include DataModelSupport

  def index
    @goal = FocusAreaGroup.find(params[:goal_id])
  end

  def show
    @target = FocusArea.find(params[:id])
    authorize @target
  end

  def new
    @goal = FocusAreaGroup.find(params[:goal_id])
    @target = @goal.focus_areas.build
    authorize @target
  end

  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @goal = FocusAreaGroup.find(params[:goal_id])

    position = @goal.focus_areas.maximum(:position) || 0
    @target = @goal.focus_areas.build(target_params.merge(position: position + 1))

    # authorize @target

    if @target.save
      respond_to do |format|
        format.html { redirect_to impact_card_data_model_path(@target) }
        format.turbo_stream
      end
    else
      render 'new'
    end
  end

  def edit
    @target = FocusArea.find(params[:id])
    authorize @target
  end

  def update
    @target = FocusArea.find(params[:id])
    authorize @target

    @target.assign_attributes(target_params)

    if @target.save
      respond_to do |format|
        # format.html { redirect_to impact_card_data_model_path(@target) }
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def target_params
    params.require(:focus_area).permit(DATA_MODEL_ELEMENT_PARAMS).tap do |whitelisted|
      whitelisted.delete(:code) if whitelisted[:code].blank?
    end
  end
end
