class InitiativesController < AuthenticatedController
  before_action :set_initiative, except: [:index, :create]

  resource_description do
    formats ["json"]
  end

  api :GET, "/initiatives"
  def index
    # @initiatives = current_client.initiatives
    @initiatives = Initiative.joins(:scorecard).where(:'scorecards.client_id' => current_client.id)

    render json: @initiatives
  end

  api :GET, "/initiatives/:id"
  param :id, :number, required: true
  def show
    render json: @initiative
  end

  # POST /initiatives
  # POST /initiatives.json
  def create
    scorecard_id = scorecard_id_from_params(initiative_params)
    organisation_ids = organisation_ids_from_params(initiative_params)

    attributes = initiative_params[:attributes].merge(
      scorecard_id: scorecard_id,
      organisation_ids: organisation_ids
    )

    @initiative = Initiative.new(attributes)

    respond_to do |format|
      if @initiative.save
        format.html do
          redirect_to @initiative,
                      notice: "Initiative was successfully created."
        end
        format.json do
          render json: @initiative,
                 status: :created, location: @initiative
        end
      else
        format.html { render :new }
        format.json do
          render json: @initiative.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /initiatives/1
  # PATCH/PUT /initiatives/1.json
  def update
    scorecard_id = scorecard_id_from_params(initiative_params)
    organisation_ids = organisation_ids_from_params(initiative_params)

    attributes = (initiative_params[:attributes] || {})

    attributes.merge!(scorecard_id: scorecard_id) if scorecard_id
    attributes.merge!(organisation_ids: organisation_ids) if organisation_ids

    respond_to do |format|
      if @initiative.update(attributes)
        format.json { render json: { status: :ok, location: @initiative } }
      else
        format.json do
          render json: @initiative.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /initiatives/1
  # DELETE /initiatives/1.json
  def destroy
    @initiative.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_initiative
    @initiative = current_client.initiatives.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise User::NotAuthorized
  end

  def organisation_ids_from_params(params)
    params[:relationships][:organisations][:data].map { |data| data["id"].to_i }
  rescue
    nil
  end

  def scorecard_id_from_params(params)
    params[:relationships][:scorecard][:data][:id].to_i
  rescue
    nil
  end

  def initiative_params
    params.require(:data).permit(
      attributes: [
        :name,
        :description,
        :started_at,
        :finished_at,
        :dates_confirmed,
        :contact_name,
        :contact_email,
        :contact_phone,
        :contact_website,
        :contact_position
      ],
      relationships: [
        scorecard: [data: [:id]],
        organisations: [data: [:id]]
      ]
    )
  end
end
