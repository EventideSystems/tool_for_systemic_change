class InitiativesController < AuthenticatedController
  before_action :set_initiative, only: [:show, :update, :destroy]

  resource_description do
    formats ['json']
  end

  api :GET, '/initiatives'
  def index
    @initiatives = Initiative.for_user(current_user)

    render json: @initiatives
  end

  api :GET, '/initiatives/:id'
  param :id, :number, required: true
  def show
    render json: @initiative
  end

  # POST /initiatives
  # POST /initiatives.json
  def create
    wicked_problem_id = wicked_problem_id_from_params(initiative_params)
    organisation_ids = organisation_ids_from_params(initiative_params)

    attributes = initiative_params[:attributes].merge(
      wicked_problem_id: wicked_problem_id,
      organisation_ids: organisation_ids
    )

    @initiative = Initiative.new(attributes)

    respond_to do |format|
      if @initiative.save
        format.html { redirect_to @initiative, notice: 'Initiative was successfully created.' }
        format.json { render json: @initiative, status: :created, location: @initiative }
      else
        format.html { render :new }
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /initiatives/1
  # PATCH/PUT /initiatives/1.json
  def update
    wicked_problem_id = wicked_problem_id_from_params(initiative_params)
    organisation_ids = organisation_ids_from_params(initiative_params)

    attributes = (initiative_params[:attributes] || {})

    attributes.merge!(wicked_problem_id: wicked_problem_id) if wicked_problem_id
    attributes.merge!(organisation_ids: organisation_ids) if organisation_ids

    respond_to do |format|
      if @initiative.update(attributes)
        format.html { redirect_to @initiative, notice: 'Initiative was successfully updated.' }
        format.json { render json: { status: :ok, location: @initiative } }
      else
        format.html { render :edit }
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /initiatives/1
  # DELETE /initiatives/1.json
  def destroy
    @initiative.destroy
    respond_to do |format|
      format.html { redirect_to initiatives_url, notice: 'Initiative was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_initiative
      @initiative = Initiative.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def initiative_params
      params[:initiative]
    end

    def organisation_ids_from_params(params)
      params[:relationships][:organisations][:data].map { |data| data['id'].to_i }
    rescue
      nil
    end

    def wicked_problem_id_from_params(params)
      params[:relationships][:wicked_problem][:data][:id].to_i
    rescue
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def initiative_params
      params.require(:data).permit(
        attributes: [:name, :description],
        relationships: [
          wicked_problem: [data: [:id]],
          organisations: [data: [:id]]
        ]
      )
    end
end
