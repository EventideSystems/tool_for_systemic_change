# frozen_string_literal: true

# Controller for indicators (aka characteristics)
class IndicatorsController < ApplicationController
  include DataModelSupport

  before_action :set_target, only: %i[index new create]

  def index; end

  def show
    @indicator = Characteristic.find(params[:id])
    authorize @indicator
  end

  def new
    @indicator = @target.characteristics.build
    authorize @indicator
  end

  def create
    position = @target.characteristics.maximum(:position) || 0
    @indicator = @target.characteristics.build(indicator_params.merge(position: position + 1))

    # authorize @indicator

    if @indicator.save

      respond_to do |format|
        format.html { redirect_to data_model_path(@indicator) }
        format.turbo_stream
      end
    else
      render 'new'
    end
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
        format.html { redirect_to data_model_path(@indicator) }
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def indicator_params
    params.require(:characteristic).permit(DATA_MODEL_ELEMENT_PARAMS).tap do |whitelisted|
      whitelisted[:code] = nil if whitelisted[:code].blank?
    end
  end

  def set_target
    @target = FocusArea.find(params[:target_id])
    authorize @target
  end
end
