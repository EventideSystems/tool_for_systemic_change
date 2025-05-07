# frozen_string_literal: true

# Controller for indicators (aka characteristics)
class IndicatorsController < DataElementsController
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

    success = save_element(@indicator, data_element_params[:position].presence || fallback_position(@target))

    if success
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

    success = save_element(@indicator, data_element_params[:position])

    if success
      respond_to do |format|
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  def destroy
    @indicator = Characteristic.find(params[:id])
    authorize @indicator

    if delete_element(@indicator)
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
