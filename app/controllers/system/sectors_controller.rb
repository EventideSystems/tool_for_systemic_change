module System
  class SectorsController < ApplicationController
    before_action :set_sector, only: [:show, :edit, :update, :destroy]

    skip_after_action :verify_policy_scoped, only: [:index]

    add_breadcrumb "System"
    add_breadcrumb "Sectors", :sectors_path

    def index
      @sectors = \
        System::SectorPolicy::Scope.new(pundit_user, Sector)
          .resolve
          .order(sort_order)
          .page params[:page]

      render 'sectors/index'
    end

    def show
      @content_subtitle = @sector.name
      add_breadcrumb @sector.name

      render 'sectors/show'
    end

    def new
      @sector = Sector.new
      authorize @sector, policy_class: System::SectorPolicy
      add_breadcrumb "New"

      render 'sectors/new'
    end

    def edit
      add_breadcrumb @sector.name

      render 'sectors/edit'
    end

    def create
      @sector = Sector.new(sector_params)
      authorize @sector, policy_class: System::SectorPolicy

      if @sector.save
        redirect_to system_sectors_path, notice: 'Sector was successfully created.'
      else
        render :new
      end
    end

    def update

      if @sector.update(sector_params)
        redirect_to system_sectors_path, notice: 'Sector was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @sector.destroy
      redirect_to system_sectors_path, notice: 'Sector was successfully deleted.'
    end

    def content_subtitle
      @sector&.name.presence || super
    end

    private

    def set_sector
      @sector = Sector.system_sectors.find(params[:id])
      authorize @sector, policy_class: System::SectorPolicy
    end

    def sector_params
      params.fetch(:sector, {}).permit(:name, :description, :color)
    end
  end
end
