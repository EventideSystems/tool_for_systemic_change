class WickedProblemsController < LabelsController
  include VerifyPolicies

  before_action :set_label, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update]

  sidebar_item :problems

  def index
    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(WickedProblem).order(:name).ransack(search_params[:q])
    wicked_problems = @q.result(distinct: true)

    @pagy, @wicked_problems = pagy(wicked_problems, limit: 10, link_extra: 'data-turbo-frame="labels"')

    @labels = @wicked_problems

    respond_to do |format|
      format.html { render 'labels/index', locals: { labels: @labels, label_klass: WickedProblem } }
      format.turbo_stream { render 'labels/index', locals: { labels: @labels, label_klass: WickedProblem } }
      format.css  { render 'labels/index', formats: [:css], locals: { labels: @labels  } }
    end
  end

  def show
    @wicked_problem.readonly!

    respond_to do |format|
      format.html { render :show }
      format.json { render json: @wicked_problem }
    end
  end

  def new
    @label = current_account.wicked_problems.build
    authorize @label

    respond_to do |format|
      format.html { render 'labels/new' }
      format.turbo_stream { render 'labels/new' }
    end
  end

  def edit
    respond_to do |format|
      format.html { render 'labels/edit' }
      format.turbo_stream { render 'labels/edit' }
    end
  end

  def create
    @label = current_account.wicked_problems.build(wicked_problem_params)
    authorize @label

    respond_to do |format|
      if @label.save
        @labels = policy_scope(WickedProblem).all
        format.turbo_stream { render 'labels/create', locals: { label: @label } }
        format.html { redirect_to polymorphic_path(WickedProblem), notice: 'Wicked problem / opportunity was successfully created.' }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.update('new_label_form', partial: 'labels/form', locals: { label: @label }) }
        format.html { render :new }
      end
    end
  end

  def update
    if @label.update(wicked_problem_params)
      @labels = policy_scope(WickedProblem).all
      respond_to do |format|
        format.turbo_stream { render 'labels/update', locals: { label: @label } }
        format.html { redirect_to wicked_problems_path, notice: 'Wicked problem / opportunity was successfully updated.' }
      end
    else
      render :edit
    end
  end

  def destroy
    @label.delete

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@label) }
      format.html { redirect_to polymorphic_path(WickedProblem), notice: 'Wicked problem / opportunity was successfully deleted.' }
    end
  end

  private

  def set_label
    @label = current_account.wicked_problems.find(params[:id])
    authorize @label
  end

  def wicked_problem_params
    params.fetch(:wicked_problem, {}).permit(:name, :description, :color)
  end
end
