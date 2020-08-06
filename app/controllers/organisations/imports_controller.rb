class Organisations::ImportsController < ApplicationController
  before_action :require_account_selected, only: [:new, :create, :edit, :update]
  before_action :set_organisations_import, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Organisations", :organisations_path
  add_breadcrumb "Import"

  def index
    @organisations_imports = Organisations::Import.all
  end

  def show
  end

  def new
    @organisations_import = current_account.organisations_imports.build
    authorize @organisations_import
  end

  def edit
  end

  def create
    @organisations_import = current_account.organisations_imports.build(
      organisations_import_params.merge(user: current_user)
    )
    authorize @organisations_import
    
    respond_to do |format|
      if @organisations_import.save && @organisations_import.process(current_account) 
        format.html { redirect_to organisations_path, notice: 'Organisation records successfully imported' }
        format.json { render :show, status: :created, location: @organisations_import }
      else
        format.html { render :new }
        format.json { render json: @organisations_import.errors, status: :unprocessable_entity }
      end
    end
    
    @organisations_import.destroy
    file_system = Shrine.storages[:cache]
    file_system.clear! { |path| path.mtime < Time.now - 1.hour } 
  end

  def update
    respond_to do |format|
      if @organisations_import.update(organisations_import_params)
        format.html { redirect_to @organisations_import, notice: 'Records successfully updated.' }
        format.json { render :show, status: :ok, location: @organisations_import }
      else
        format.html { render :edit }
        format.json { render json: @organisations_import.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @organisations_import.destroy
    respond_to do |format|
      format.html { redirect_to organisations_imports_url, notice: 'Import was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_organisations_import
      @organisations_import = Organisations::Import.find(params[:id])
      authorize @organisations_import
    end

    def organisations_import_params
       params.fetch(:organisations_import, {}).permit(:import)
    end
end
