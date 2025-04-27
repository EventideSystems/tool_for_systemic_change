# frozen_string_literal: true

# Controller for goals (aka focus areas)
# This controller is a similar to the IndicatorsController, just at a different nesting level in the data model.
class GoalsController < ApplicationController
  include DataModelSupport

  before_action :set_data_model, only: %i[index new create]

  def index; end

  def show
    @goal = FocusAreaGroup.find(params[:id])
    authorize @goal
  end

  def new
    @goal = @data_model.focus_area_groups.build
    authorize @goal
  end

  def create
    position = @data_model.focus_area_groups.maximum(:position) || 0
    @goal = @data_model.focus_area_groups.build(goal_params.merge(position: position + 1))

    authorize @goal

    if @goal.save
      respond_to do |format|
        # format.html { redirect_to data_model_path(@goal) }
        format.turbo_stream
      end
    else
      render 'new'
    end
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
        format.html { redirect_to data_model_path(@goal) }
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def goal_params
    params.require(:focus_area_group).permit(DATA_MODEL_ELEMENT_PARAMS).tap do |whitelisted|
      whitelisted[:code] = nil if whitelisted[:code].blank?
    end
  end

  def set_data_model
    @data_model = DataModel.find(params[:data_model_id])
    authorize @data_model
  end
end
