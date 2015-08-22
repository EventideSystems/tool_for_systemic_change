class OrganisationsController < AuthenticatedController
  before_action :set_organisation, only: [:show, :edit, :update, :destroy]

  # GET /organisations
  # GET /organisations.json
  def index
    @organisations = Organisation.no_subclasses.for_user(current_user)

    render json: @organisations
  end

  # GET /organisations/1
  # GET /organisations/1.json
  def show
    render json: @organisation
  end

  # GET /organisations/new
  def new
    @organisation = Organisation.new
  end

  # GET /organisations/1/edit
  def edit
  end

  # POST /organisations
  # POST /organisations.json
  def create
    administrating_organisation_id = administrating_organisation_id_from_params(organisation_params)
    administrating_organisation_id = current_user.administrating_organisation.id unless administrating_organisation_id

    attributes = organisation_params[:attributes].merge(
      administrating_organisation_id: administrating_organisation_id
    )
    @organisation = Organisation.new(attributes)

    respond_to do |format|
      if @organisation.save
        format.html { redirect_to @organisation, notice: 'Organisation was successfully created.' }
        format.json { render json: @organisation, status: :created, location: @community }
      else
        format.html { render :new }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organisations/1
  # PATCH/PUT /organisations/1.json
  def update
    administrating_organisation_id = administrating_organisation_id_from_params(organisation_params)

    attributes = organisation_params[:attributes].merge(
      administrating_organisation_id: administrating_organisation_id
    )

    respond_to do |format|
      if @organisation.update(attributes)
        format.html { redirect_to @organisation, notice: 'Organisation was successfully updated.' }
        format.json { render json: { status: :ok, location: @organisation } }
      else
        format.html { render :edit }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisations/1
  # DELETE /organisations/1.json
  def destroy
    @organisation.destroy
    respond_to do |format|
      format.html { redirect_to organisations_url, notice: 'Organisation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organisation
      @organisation = Organisation.no_subclasses.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    end

    # SMELL Dupe of code in wicked_problems_controller. Refactor into concern
    def administrating_organisation_id_from_params(params)
      params[:relationships][:administrating_organisation][:data][:id].to_i
    rescue
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organisation_params
      params.require(:data).permit(
        attributes: [:name, :description],
        relationships: [
          # SMELL Not required, and we'd have to ensure it can take multiple
          # problems
          # wicked_problems: [data: [:id]],
          administrating_organisation: [data: [:id]]
        ]
      )
    end
end
