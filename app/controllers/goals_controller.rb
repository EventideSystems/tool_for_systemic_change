# frozen_string_literal: true

# Controller for goals (aka focus areas)
# This controller is a similar to the IndicatorsController, just at a different nesting level in the data model.
class GoalsController < DataElementsController
  before_action :set_parent, only: %i[index new create]

  def index; end

  def show
    @goal = FocusAreaGroup.find(params[:id])
    authorize @goal
  end

  def new
    @goal = @data_model.children.build(position: next_position(@data_model.children))
    @max_position = @data_model.children.maximum(:position).to_i + 1
    authorize @goal
  end

  def create # rubocop:disable Metrics/MethodLength
    @goal = @data_model.children.build(data_element_params)

    authorize @goal

    @goal.assign_attributes(data_element_params)

    success = save_element(@goal, data_element_params[:position].presence || fallback_position(@data_model))

    if success
      respond_to do |format|
        format.turbo_stream
      end
    else
      render 'new'
    end
  end

  def edit
    @goal = FocusAreaGroup.find(params[:id])
    @max_position = @goal.parent.children.maximum(:position)
    authorize @goal
  end

  def update # rubocop:disable Metrics/MethodLength
    @goal = FocusAreaGroup.find(params[:id])
    authorize @goal

    @goal.assign_attributes(data_element_params)
    @goal.siblings

    success = save_element(@goal, data_element_params[:position])

    if success
      respond_to do |format|
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  def destroy
    @goal = FocusAreaGroup.find(params[:id])
    authorize @goal

    if delete_element(@goal)
      respond_to do |format|
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def data_element_params
    params.require(:focus_area_group).permit(DATA_MODEL_ELEMENT_PARAMS).tap do |whitelisted|
      whitelisted[:code] = nil if whitelisted[:code].blank?
    end
  end

  def set_parent
    @data_model = DataModel.find(params[:data_model_id])
    authorize @data_model
  end
end
