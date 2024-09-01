class FocusAreaGroupsController < ApplicationController
  include VerifyPolicies

  before_action :set_focus_area_group, only: [:show, :edit, :update, :destroy]

  # add_breadcrumb "System", :focus_area_groups_path

  def index
    @focus_area_groups = \
      policy_scope(FocusAreaGroup)
        .where(account: current_account)
        .order(sort_order)
        .page(params[:page])
  end

  def show
  end

  def new
    @focus_area_group = current_account.build_focus_area_group
    authorize @focus_area_group
  end

  def edit
  end

  def create
    @focus_area_group = current_account.build_focus_area_group(focus_area_group_params)
    authorize @focus_area_group

    if @focus_area_group.save
      redirect_to focus_area_groups_path, notice: 'Focus area group was successfully created.'
    else
      render :new
    end
  end

  def update
    if @focus_area_group.update(focus_area_group_params)
      redirect_to focus_area_groups_path, notice: 'Focus area group was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @focus_area_group.focus_areas do |focus_area|
        focus_area.characteristics.delete_all
        focus_area.delete
      end

      @focus_area_group.delete
    end

    redirect_to focus_area_groups_url, notice: 'Focus area group was successfully deleted.'
  end

  def content_subtitle
    @focus_area_group&.name.presence || super
  end

  private

  def set_focus_area_group
    @focus_area_group = FocusAreaGroup.find(params[:id])
    authorize @focus_area_group
  end

  def focus_area_group_params
    params.fetch(:focus_area_group, {}).permit(:name, :description, :position, :video_tutorial_id)
  end
end
