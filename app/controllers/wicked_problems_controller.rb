class WickedProblemsController < AuthenticatedController
  before_action :set_wicked_problem, only: [:show, :edit, :update, :destroy]

  resource_description do
    formats ['json']
  end

  api :GET, '/wicked_problems'
  def index
    @wicked_problems = WickedProblem.where(client_id: current_client.id).all

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
    attributes = wicked_problem_params[:attributes].merge(
      client_id: current_client.id
    )
    @wicked_problem = WickedProblem.new(attributes)

    respond_to do |format|
      if @wicked_problem.save
        format.json { render json: @wicked_problem, status: :created, location: @community }
      else
        format.json { render json: @wicked_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wicked_problems/1
  # PATCH/PUT /wicked_problems/1.json
  def update
    attributes = wicked_problem_params[:attributes].merge(
      client_id: current_client.id
    )

    respond_to do |format|
      if @wicked_problem.update(attributes)
        format.json { render json: { status: :ok, location: @wicked_problem } }
      else
        format.json { render json: @wicked_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wicked_problems/1
  # DELETE /wicked_problems/1.json
  def destroy
    @wicked_problem.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    def set_wicked_problem
      @wicked_problem = current_client.wicked_problems.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise User::NotAuthorized
    end

    def wicked_problem_params
      params.require(:data).permit(
        attributes: [:name, :description],
        relationships: [
          client: [data: [:id]]
        ]
      )
    end
end
