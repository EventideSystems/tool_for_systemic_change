class Organisations::ImportsController < ApplicationController
  before_action :set_organisations_import, only: [:show, :edit, :update, :destroy]

  # GET /organisations/imports
  # GET /organisations/imports.json
  def index
    @organisations_imports = Organisations::Import.all
  end

  # GET /organisations/imports/1
  # GET /organisations/imports/1.json
  def show
  end

  # GET /organisations/imports/new
  def new
    @organisations_import = Organisations::Import.new
  end

  # GET /organisations/imports/1/edit
  def edit
  end

  # POST /organisations/imports
  # POST /organisations/imports.json
  def create
    @organisations_import = Organisations::Import.new(organisations_import_params)

    respond_to do |format|
      if @organisations_import.save
        format.html { redirect_to @organisations_import, notice: 'Import was successfully created.' }
        format.json { render :show, status: :created, location: @organisations_import }
      else
        format.html { render :new }
        format.json { render json: @organisations_import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organisations/imports/1
  # PATCH/PUT /organisations/imports/1.json
  def update
    respond_to do |format|
      if @organisations_import.update(organisations_import_params)
        format.html { redirect_to @organisations_import, notice: 'Import was successfully updated.' }
        format.json { render :show, status: :ok, location: @organisations_import }
      else
        format.html { render :edit }
        format.json { render json: @organisations_import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisations/imports/1
  # DELETE /organisations/imports/1.json
  def destroy
    @organisations_import.destroy
    respond_to do |format|
      format.html { redirect_to organisations_imports_url, notice: 'Import was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organisations_import
      @organisations_import = Organisations::Import.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organisations_import_params
      params.fetch(:organisations_import, {})
    end
end
