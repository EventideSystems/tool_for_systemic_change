class OrganisationsController < AuthenticatedController
  before_action :set_organisation, only: [:show, :edit, :update, :destroy]

  resource_description do
    formats ['json']
  end

  api :GET, '/organisations'
  def index
    @organisations = Organisation.for_user(current_user)

    render json: @organisations
  end

  api :GET, '/organisations/:id'
  param :id, :number, required: true
  def show
    render json: @organisation
  end

  # POST /organisations
  # POST /organisations.json
  def create
    client_id = client_id_from_params(organisation_params)
    client_id = current_user.client.id unless client_id

    attributes = organisation_params[:attributes].merge(
      client_id: client_id
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
    client_id = client_id_from_params(organisation_params)

    attributes = organisation_params[:attributes].merge(
      client_id: client_id
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
      @organisation = Organisation.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    end

    # SMELL Dupe of code in wicked_problems_controller. Refactor into concern
    def client_id_from_params(params)
      params[:relationships][:client][:data][:id].to_i
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
          client: [data: [:id]]
        ]
      )
    end
end
