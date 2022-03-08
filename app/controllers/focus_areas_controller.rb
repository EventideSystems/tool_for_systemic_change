# frozen_string_literal: true

class FocusAreasController < ApplicationController
  before_action :set_focus_area, only: %i[show edit update destroy]

  add_breadcrumb 'System', :focus_areas_path

  def index
    @focus_areas = policy_scope(FocusArea)
                   .unscoped.joins(:focus_area_group)
                   .order(sort_order)
                   .page params[:page]
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

    respond_to do |format|
      if @focus_area.save
        format.html { redirect_to focus_areas_path, notice: 'Focus area was successfully created.' }
        format.json { render :show, status: :created, location: @focus_area }
      else
        format.html { render :new }
        format.json { render json: @focus_area.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @focus_area.update(focus_area_params)
        format.html { redirect_to focus_areas_path, notice: 'Focus area was successfully updated.' }
        format.json { render :show, status: :ok, location: @focus_area }
      else
        format.html { render :edit }
        format.json { render json: @focus_area.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @focus_area.destroy
    respond_to do |format|
      format.html { redirect_to focus_areas_url, notice: 'Focus area was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def content_subtitle
    return @focus_area.name if @focus_area.present?

    super
  end

  private

  def set_focus_area
    @focus_area = FocusArea.find(params[:id])
    authorize @focus_area
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
