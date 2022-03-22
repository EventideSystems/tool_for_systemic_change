class InitiativesOrganisationsController < ApplicationController
  before_action :set_initiatives_organisation, only: [:show, :edit, :update, :destroy]

  # GET /initiatives_organisations
  # GET /initiatives_organisations.json
  def index
    @initiatives_organisations = InitiativesOrganisation.all
  end

  # GET /initiatives_organisations/1
  # GET /initiatives_organisations/1.json
  def show
  end

  # GET /initiatives_organisations/new
  def new
    @initiatives_organisation = InitiativesOrganisation.new
  end

  # GET /initiatives_organisations/1/edit
  def edit
  end

  # POST /initiatives_organisations
  # POST /initiatives_organisations.json
  def create
    @initiatives_organisation = InitiativesOrganisation.new(initiatives_organisation_params)

    respond_to do |format|
      if @initiatives_organisation.save
        format.html { redirect_to @initiatives_organisation, notice: 'Initiatives organisation was successfully created.' }
        format.json { render :show, status: :created, location: @initiatives_organisation }
      else
        format.html { render :new }
        format.json { render json: @initiatives_organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /initiatives_organisations/1
  # PATCH/PUT /initiatives_organisations/1.json
  def update
    respond_to do |format|
      if @initiatives_organisation.update(initiatives_organisation_params)
        format.html { redirect_to @initiatives_organisation, notice: 'Initiatives organisation was successfully updated.' }
        format.json { render :show, status: :ok, location: @initiatives_organisation }
      else
        format.html { render :edit }
        format.json { render json: @initiatives_organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /initiatives_organisations/1
  # DELETE /initiatives_organisations/1.json
  def destroy
    @initiatives_organisation.destroy
    respond_to do |format|
      format.html { redirect_to initiatives_organisations_url, notice: 'Initiatives organisation was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_initiatives_organisation
      @initiatives_organisation = InitiativesOrganisation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def initiatives_organisation_params
      params.fetch(:initiatives_organisation, {})
    end
end
