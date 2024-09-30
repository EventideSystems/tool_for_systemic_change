class WickedProblemsController < LabelsController
  include VerifyPolicies

  sidebar_item :problems

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

  private

  def label_klass
    WickedProblem
  end

  def wicked_problem_params
    params.fetch(:wicked_problem, {}).permit(:name, :description, :color)
  end
end
