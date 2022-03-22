class FocusAreaGroupsController < ApplicationController
  before_action :set_focus_area_group, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "System", :focus_area_groups_path

  # GET /focus_area_groups
  # GET /focus_area_groups.json
  def index
    @focus_area_groups = policy_scope(FocusAreaGroup).unscoped.order(sort_order).page params[:page]
  end

  def show
  end

  def new
    @focus_area_group = FocusAreaGroup.new
    authorize @focus_area_group
  end

  def edit
  end

  def create
    @focus_area_group = FocusAreaGroup.new(focus_area_group_params)
    authorize @focus_area_group

    respond_to do |format|
      if @focus_area_group.save
        format.html { redirect_to focus_area_groups_path, notice: 'Focus area group was successfully created.' }
        format.json { render :show, status: :created, location: @focus_area_group }
      else
        format.html { render :new }
        format.json { render json: @focus_area_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @focus_area_group.update(focus_area_group_params)
        format.html { redirect_to focus_area_groups_path, notice: 'Focus area group was successfully updated.' }
        format.json { render :show, status: :ok, location: @focus_area_group }
      else
        format.html { render :edit }
        format.json { render json: @focus_area_group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @focus_area_group.destroy
    respond_to do |format|
      format.html { redirect_to focus_area_groups_url, notice: 'Focus area group was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def content_subtitle
    return @focus_area_group.name if @focus_area_group.present?
    super
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
