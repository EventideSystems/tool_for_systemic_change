# frozen_string_literal: true

# Controller for indicators (aka characteristics)
class IndicatorsController < ApplicationController
  include DataModelSupport

  before_action :set_parent, only: %i[index new create]

  def index; end

  def show
    @indicator = Characteristic.find(params[:id])
    authorize @indicator
  end

  def new
    @indicator = @target.children.build(position: next_position(@target.children))
    @max_position = @indicator.parent.children.maximum(:position).to_i + 1
    authorize @indicator
  end

  def create
    @indicator = @target.children.build(data_element_params)
    authorize @indicator

    if @indicator.save

      respond_to do |format|
        format.turbo_stream
      end
    else
      render 'new'
    end
  end

  def edit
    @indicator = Characteristic.find(params[:id])
    @max_position = @indicator.parent.children.maximum(:position)
    authorize @indicator
  end

  def update # rubocop:disable Metrics/MethodLength
    @indicator = Characteristic.find(params[:id])
    authorize @indicator

    @indicator.assign_attributes(data_element_params)

    if @indicator.save
      respond_to do |format|
        format.html { redirect_to data_model_path(@indicator) }
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  def destroy
    @indicator = Characteristic.find(params[:id])
    authorize @indicator

    if @indicator.destroy
      respond_to do |format|
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def data_element_params
    params.require(:characteristic).permit(DATA_MODEL_ELEMENT_PARAMS).tap do |whitelisted|
      whitelisted[:code] = nil if whitelisted[:code].blank?
    end
  end

  def set_parent
    @target = FocusArea.find(params[:target_id])
    authorize @target
  end
end
