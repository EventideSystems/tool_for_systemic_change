# frozen_string_literal: true

class FocusAreasController < ApplicationController
  before_action :set_focus_area, only: %i[show edit update destroy]
  before_action :set_focus_area_groups, only: %i[new edit]

  add_breadcrumb 'System', :focus_areas_path

  def index
    @focus_areas = \
      policy_scope(FocusArea)
        .joins(focus_area_group: :account)
        .where('focus_area_groups.account': current_account)
        .order(sort_order)
        .page(params[:page])
  end

  def show; end

  def new
    @focus_area = FocusArea.new
    authorize @focus_area
  end

  def edit; end

  def create
    @focus_area = FocusArea.new(focus_area_params)
    authorize @focus_area

    if @focus_area.save
      redirect_to focus_areas_path, notice: 'Focus area was successfully created.'
    else
      render :new
    end
  end

  def update
    if @focus_area.update(focus_area_params)
      redirect_to focus_areas_path, notice: 'Focus area was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @focus_area.characteristics.delete_all
      @focus_area.delete
    end

    redirect_to focus_areas_url, notice: 'Focus area was successfully deleted.'
  end

  def content_subtitle
    @focus_area&.name.presence || super
  end

  private

  def set_focus_area
    @focus_area = FocusArea.find(params[:id])
    authorize @focus_area
  end

  def set_focus_area_groups
    @focus_area_groups = policy_scope(FocusAreaGroup).where(account: current_account)
  end

  def focus_area_params
    params
      .fetch(:focus_area, {})
      .permit(
        :name,
        :description,
        :position,
        :icon_name,
        :actual_color,
        :planned_color,
        :focus_area_group_id,
        :video_tutorial_id
      )
  end
end
