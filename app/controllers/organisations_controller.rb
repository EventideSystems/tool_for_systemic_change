class OrganisationsController < AuthenticatedController
  before_action :set_organisation, only: [:show, :edit, :update, :destroy]

  resource_description do
    formats ['json']
  end

  api :GET, '/organisations'
  def index
    query = Organisation.where(client_id: current_client.id)
    @organisations = finder_for_pagination(query).all

    render json: @organisations
  end

  api :GET, '/organisations/:id'
  param :id, :number, required: true
  def show
    render json: @organisation
  end

  api :POST, '/organisations'
  def create
    attributes = organisation_params[:attributes].merge(
      client_id: current_client.id
    )
    @organisation = Organisation.new(attributes)

    respond_to do |format|
      if @organisation.save
        format.json { render json: @organisation, status: :created, location: @community }
      else
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  api :PUT, '/organisations'
  def update
    attributes = organisation_params[:attributes].merge(
      client_id: current_client.id
    )

    respond_to do |format|
      if @organisation.update(attributes)
        format.json { render json: { status: :ok, location: @organisation } }
      else
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisations/1
  # DELETE /organisations/1.json
  def destroy
    @organisation.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

    def set_organisation
      @organisation = current_client.organisations.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise User::NotAuthorized
    end

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
