class SectorsController < ApplicationController
  before_action :set_sector, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Sectors", :sectors_path

  def index
    @sectors = policy_scope(Sector).order(sort_order).page params[:page]
  end

  def show
    @content_subtitle = @sector.name
    add_breadcrumb @sector.name
  end

  def new
    @sector = current_account.sectors.build
    authorize @sector
    add_breadcrumb "New"
  end

  def edit
    add_breadcrumb @sector.name
  end

  def create
    @sector = current_account.sectors.build(sector_params)
    authorize @sector

    if @sector.save
      redirect_to sectors_path, notice: 'Sector was successfully created.'
    else
      render :new
    end
  end

  def update
    if @sector.update(sector_params)
      redirect_to sectors_path, notice: 'Sector was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @sector.destroy
    redirect_to sectors_url, notice: 'Sector was successfully deleted.'
  end

  def content_subtitle
    @sector&.name.presence || super
  end

  private

  def set_sector
    @sector = current_account.sectors.find(params[:id])
    authorize @sector
  end

  def sector_params
    params.fetch(:sector, {}).permit(:name, :description, :color)
  end
end
