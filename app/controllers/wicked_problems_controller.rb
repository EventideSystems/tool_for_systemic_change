class WickedProblemsController < AuthenticatedController
  before_action :set_wicked_problem, only: [:show, :edit, :update, :destroy]

  resource_description do
    formats ['json']
  end

  api :GET, '/wicked_problems'
  def index
    @wicked_problems = WickedProblem.for_user(current_user)

    render json: @wicked_problems
  end

  api :GET, '/wicked_problems/:id'
  param :id, :number, required: true
  def show
    render json: @wicked_problem
  end

  # POST /wicked_problems
  # POST /wicked_problems.json
  def create
    client_id = client_id_from_params(wicked_problem_params)
    client_id = current_user.client.id unless client_id

    attributes = wicked_problem_params[:attributes].merge(
      client_id: client_id
    )
    @wicked_problem = WickedProblem.new(attributes)

    respond_to do |format|
      if @wicked_problem.save
        format.html { redirect_to @wicked_problem, notice: 'Wicked Problem was successfully created.' }
        format.json { render json: @wicked_problem, status: :created, location: @community }
      else
        format.html { render :new }
        format.json { render json: @wicked_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wicked_problems/1
  # PATCH/PUT /wicked_problems/1.json
  def update
    client_id = client_id_from_params(wicked_problem_params)

    attributes = wicked_problem_params[:attributes].merge(
      client_id: client_id
    )

    respond_to do |format|
      if @wicked_problem.update(attributes)
        format.html { redirect_to @wicked_problem, notice: 'Wicked Problem was successfully updated.' }
        format.json { render json: { status: :ok, location: @wicked_problem } }
      else
        format.html { render :edit }
        format.json { render json: @wicked_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wicked_problems/1
  # DELETE /wicked_problems/1.json
  def destroy
    @wicked_problem.destroy
    respond_to do |format|
      format.html { redirect_to wicked_problems_url, notice: 'Wicked Problem was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wicked_problem
      @wicked_problem = WickedProblem.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    end

    # SMELL Dupe of code in wicked_problems_controller. Refactor into concern
    def client_id_from_params(params)
      params[:relationships][:client][:data][:id].to_i
    rescue
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wicked_problem_params
      params.require(:data).permit(
        attributes: [:name, :description],
        relationships: [
          client: [data: [:id]]
        ]
      )
    end
end
