class Initiatives::ImportsController < ApplicationController
  before_action :require_account_selected, only: [:new, :create, :edit, :update]
  before_action :set_initiatives_import, only: [:show, :edit, :update, :destroy]

  # def show
  # end

  def new
    @initiatives_import = current_account.initiatives_imports.build
    authorize @initiatives_import
  end

  # def edit
  # end

  def create
    @initiatives_import = current_account.initiatives_imports.build(
      initiatives_import_params.merge(user: current_user)
    ) 
    authorize @initiatives_import
    
    respond_to do |format|
      if @initiatives_import.save && @initiatives_import.process(current_account)
        format.html { redirect_to initiatives_path, notice: 'Initiative records successfully imported.' }
        format.json { render :show, status: :created, location: @initiatives_import }
      else
        format.html { render :new }
        format.json { render json: @initiatives_import.errors, status: :unprocessable_entity }
      end
    end
    
    @initiatives_import.destroy
    file_system = Shrine.storages[:cache]
    file_system.clear!(older_than: Time.now - 1.hour)
  end

  def update
    respond_to do |format|
      if @initiatives_import.update(initiatives_import_params)
        format.html { redirect_to @initiatives_import, notice: 'Import was successfully updated.' }
        format.json { render :show, status: :ok, location: @initiatives_import }
      else
        format.html { render :edit }
        format.json { render json: @initiatives_import.errors, status: :unprocessable_entity }
      end
    end
  end

  # def destroy
  #   @initiatives_import.destroy
  #   respond_to do |format|
  #     format.html { redirect_to initiatives_imports_url, notice: 'Import was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    def set_initiatives_import
      @initiatives_import = Initiatives::Import.find(params[:id])
      authorize @initiatives_import
    end

    def initiatives_import_params
      params.fetch(:initiatives_import, {}).permit(:import)
    end
end
