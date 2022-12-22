class StakeholderTypesController < ApplicationController
  before_action :set_stakeholder_type, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Stakeholder Types", :stakeholder_types_path

  def index
    @stakeholder_types = policy_scope(StakeholderType).order(sort_order).page params[:page]
  end

  def show
    @content_subtitle = @stakeholder_type.name
    add_breadcrumb @stakeholder_type.name
  end

  def new
    @stakeholder_type = current_account.stakeholder_types.build
    authorize @stakeholder_type
    add_breadcrumb "New"
  end

  def edit
    add_breadcrumb @stakeholder_type.name
  end

  def create
    @stakeholder_type = current_account.stakeholder_types.build(stakeholder_type_params)
    authorize @stakeholder_type

    if @stakeholder_type.save
      redirect_to stakeholder_types_path, notice: 'Stakeholder Type was successfully created.'
    else
      render :new
    end
  end

  def update
    if @stakeholder_type.update(stakeholder_type_params)
      redirect_to stakeholder_types_path, notice: 'Stakeholder Type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @stakeholder_type.destroy
    redirect_to stakeholder_types_url, notice: 'Stakeholder Type was successfully deleted.'
  end

  def content_subtitle
    @stakeholder_type&.name.presence || super
  end

  private

  def set_stakeholder_type
    @stakeholder_type = current_account.stakeholder_types.find(params[:id])
    authorize @stakeholder_type
  end

  def stakeholder_type_params
    params.fetch(:stakeholder_type, {}).permit(:name, :description, :color)
  end
end
