# frozen_string_literal: true

# Controller for targets (aka focus areas)
# This controller is a similar to the IndicatorsController, just at a different nesting level in the data model.
class TargetsController < ApplicationController
  include DataModelSupport

  before_action :set_parent, only: %i[index new create]

  def index; end

  def show
    @target = FocusArea.find(params[:id])
    authorize @target
  end

  def new
    @target = @goal.children.build(position: next_position(@goal.children))
    @max_position = @goal.children.maximum(:position).to_i + 1
    authorize @target
  end

  def create
    position = @goal.children.maximum(:position) || 0
    @target = @goal.children.build(data_element_params.merge(position: position + 1))

    authorize @target

    if @target.save
      respond_to do |format|
        format.turbo_stream
      end
    else
      render 'new'
    end
  end

  def edit
    @target = FocusArea.find(params[:id])
    @max_position = @target.parent.children.maximum(:position)
    authorize @target
  end

  def update
    @target = FocusArea.find(params[:id])
    authorize @target

    @target.assign_attributes(data_element_params)

    if @target.save
      respond_to do |format|
        # format.html { redirect_to data_model_path(@target) }
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  def destroy
    @target = FocusArea.find(params[:id])
    authorize @target

    if @target.delete
      respond_to do |format|
        format.turbo_stream
      end
    else
      render 'edit'
    end
  end

  private

  def data_element_params
    params.require(:focus_area).permit(DATA_MODEL_ELEMENT_PARAMS).tap do |whitelisted|
      whitelisted[:code] = nil if whitelisted[:code].blank?
    end
  end

  def set_parent
    @goal = FocusAreaGroup.find(params[:goal_id])
    authorize @goal
  end
end
