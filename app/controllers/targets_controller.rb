# frozen_string_literal: true

# Controller for targets (aka focus areas)
# This controller is a similar to the IndicatorsController, just at a different nesting level in the data model.
class TargetsController < ApplicationController
  def show
    @target = FocusArea.find(params[:id])
    authorize @target
  end

  def edit
    @target = FocusArea.find(params[:id])
    authorize @target
  end

  def update # rubocop:disable Metrics/MethodLength
    @target = FocusArea.find(params[:id])
    authorize @target

    @target.assign_attributes(target_params)

    if @target.save
      respond_to do |format|
        format.html { redirect_to impact_card_data_model_path(@target) }
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def target_params
    params.require(:focus_area).permit(
      :code,
      :color,
      :description,
      :name,
      :position,
      :short_name
    ).tap do |whitelisted|
      whitelisted.delete(:code) if whitelisted[:code].blank?
    end
  end
end
