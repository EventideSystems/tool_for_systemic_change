class SectorsController < ApplicationController
  before_action :set_sector, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "System"
  add_breadcrumb "Sectors", :sectors_path

  def index
    @sectors = policy_scope(Sector).unscoped.order(sort_order).page params[:page]
  end

  def show
    @content_subtitle = @sector.name
    add_breadcrumb @sector.name
  end

  def new
    @sector = Sector.new
    authorize @sector
    add_breadcrumb "New"
  end

  def edit
    add_breadcrumb @sector.name
  end

  def create
    @sector = Sector.new(sector_params)
    authorize @sector

    respond_to do |format|
      if @sector.save
        format.html { redirect_to sectors_path, notice: 'Sector was successfully created.' }
        format.json { render :show, status: :created, location: @sector }
      else
        format.html { render :new }
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @sector.update(sector_params)
        format.html { redirect_to sectors_path, notice: 'Sector was successfully updated.' }
        format.json { render :show, status: :ok, location: @sector }
      else
        format.html { render :edit }
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sector.destroy
    respond_to do |format|
      format.html { redirect_to sectors_url, notice: 'Sector was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def content_subtitle
    return @sector.name if @sector.present?
    super
  end

  private

    def set_sector
      @sector = Sector.find(params[:id])
      authorize @sector
    end

    def sector_params
      params.fetch(:sector, {}).permit(:name, :description, :color)
    end
end
