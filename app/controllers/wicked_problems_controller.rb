class WickedProblemsController < AuthenticatedController
  before_action :set_wicked_problem, only: [:show, :edit, :update, :destroy]



  # GET /wicked_problems.json
  def index
    @wicked_problems = WickedProblem.for_user(current_user)

    render json: @wicked_problems
  end

  # GET /wicked_problems/1
  # GET /wicked_problems/1.json
  def show
    render json: @wicked_problem
  end

  # GET /wicked_problems/new
  def new
    @wicked_problem = WickedProblem.new
  end

  # GET /wicked_problems/1/edit
  def edit
  end

  # POST /wicked_problems
  # POST /wicked_problems.json
  def create
    administrating_organisation_id = administrating_organisation_id_from_params(wicked_problem_params)
    community_id = community_id_from_params(wicked_problem_params)

    attributes = wicked_problem_params[:attributes].merge(
      administrating_organisation_id: administrating_organisation_id,
      community_id: community_id
    )
    @wicked_problem = WickedProblem.new(attributes)

    respond_to do |format|
      if @wicked_problem.save
        format.html { redirect_to @wicked_problem, notice: 'WickedProblem was successfully created.' }
        format.json { render json: @wicked_problem, status: :created, location: @wicked_problem }
      else
        format.html { render :new }
        format.json { render json: @wicked_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wicked_problems/1
  # PATCH/PUT /wicked_problems/1.json
  def update
    administrating_organisation_id = administrating_organisation_id_from_params(wicked_problem_params)
    community_id = community_id_from_params(wicked_problem_params)

    attributes = wicked_problem_params[:attributes].merge(
      administrating_organisation_id: administrating_organisation_id,
      community_id: community_id
    )

    respond_to do |format|
      if @wicked_problem.update(attributes)
        format.html { redirect_to @wicked_problem, notice: 'WickedProblem was successfully updated.' }
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
      format.html { redirect_to wicked_problems_url, notice: 'WickedProblem was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_wicked_problem
      @wicked_problem = WickedProblem.for_user(current_user).find(params[:id]) rescue (raise User::NotAuthorized )
    end

    def wicked_problem_params
      params.require(:data).permit(
        attributes: [:name, :description],
        relationships: [
          community: [data: [:id]],
          administrating_organisation: [data: [:id]]
        ]
      )
    end

    def administrating_organisation_id_from_params(params)
      params[:relationships][:administrating_organisation][:data][:id].to_i
    end

    def community_id_from_params(params)
      params[:relationships][:community][:data][:id].to_i
    end
end
