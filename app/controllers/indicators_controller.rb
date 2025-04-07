# frozen_string_literal: true

# Controller for indicators (aka characteristics)
class IndicatorsController < ApplicationController
  def show
    @indicator = Characteristic.find(params[:id])
    authorize @indicator
  end

  def edit
    @indicator = Characteristic.find(params[:id])
    authorize @indicator
  end

  def update # rubocop:disable Metrics/MethodLength
    @indicator = Characteristic.find(params[:id])
    authorize @indicator

    @indicator.assign_attributes(indicator_params)

    if @indicator.save
      respond_to do |format|
        format.html { redirect_to impact_card_data_model_path(@indicator) }
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def indicator_params
    params.require(:characteristic).permit(
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
