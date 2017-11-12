class ScorecardsController < ApplicationController
  before_action :set_scorecard, only: [:show, :edit, :update, :destroy, :show_shared_link, :copy, :copy_options, :merge, :merge_options] 
  before_action :set_active_tab, only: [:show] 
  before_action :require_account_selected, only: [:new, :create, :edit, :update, :show_shared_link] 

  add_breadcrumb "Scorecards", :scorecards_path
  
  def index
    @scorecards = policy_scope(Scorecard).order(sort_order).page params[:page]
  end

  def show
    @selected_date = params[:selected_date]
    @parsed_selected_date = @selected_date.blank? ? nil : Date.parse(@selected_date)
    
    @focus_areas = FocusArea.ordered_by_group_position
    @initiatives = if @parsed_selected_date.present? 
      @scorecard.initiatives
        .where('started_at <= ? OR started_at IS NULL', @parsed_selected_date)
        .where('finished_at >= ? OR finished_at IS NULL', @parsed_selected_date)
        .order(name: :asc)
    else  
      @scorecard.initiatives.order(name: :asc)
    end
    
    add_breadcrumb @scorecard.name
    
    respond_to do |format|
      format.html 
      format.pdf do
        render pdf: "scorecard",
          layout: 'pdf.html.erb',
          orientation: 'Landscape',
          viewport_size: '1280x1024', 
          print_media_type: false,
          grayscale: false,
          background: true,
          show_as_html: params.key?('debug'),
          footer: { right: 'Page [page] of [topage]' }
      end 
    end
    
  end

  def new
    @scorecard = current_account.scorecards.build
    authorize @scorecard
    @scorecard.initiatives.build
   # @scorecard.initiatives.first.initiatives_organisations.build
    add_breadcrumb "New Scorecard"
  end

  def edit
    add_breadcrumb @scorecard.name
  end

  def create
    @scorecard = current_account.scorecards.build(scorecard_params)
    authorize @scorecard

    respond_to do |format|
      if @scorecard.save
        format.html { redirect_to scorecard_path(@scorecard), notice: 'Scorecard was successfully created.' }
        format.json { render :show, status: :created, location: @scorecard }
      else
        format.html { render :new }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @scorecard.update(scorecard_params)
        format.html { redirect_to @scorecard, notice: 'Scorecard was successfully updated.' }
        format.json { render :show, status: :ok, location: @scorecard }
      else
        format.html { render :edit }
        format.json { render json: @scorecard.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @scorecard.destroy
    respond_to do |format|
      format.html { redirect_to scorecards_url, notice: 'Scorecard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def shared
    
  end
  
  def show_shared_link
    render layout: false
  end

  def copy_options
    render layout: false
  end
  
  def copy
    new_name = params.dig(:new_name) 
    @copied_scorecard = params.dig(:copy) == 'deep' ? @scorecard.deep_copy(new_name) : @scorecard.copy(new_name) 
    respond_to do |format|
      if @copied_scorecard.present?
        format.html { redirect_to scorecard_path(@copied_scorecard), notice: 'Scorecard was successfully copied.' }
        format.json { render :show, status: :ok, location: @copied_scorecard }
      else
        format.html { render :edit }
        format.json { render json: @copied_scorecard.errors, status: :unprocessable_entity }
      end
    end 
  end
  
  def merge_options
    render layout: false
  end
  
  def merge
    @other_scorecard = current_account.scorecards.find(params[:other_scorecard_id])
    @merged_scorecard = @scorecard.merge(@other_scorecard)
    respond_to do |format|
      if @scorecard.present?
        format.html { redirect_to scorecard_path(@merged_scorecard), notice: 'Scorecards were successfully merged.' }
        format.json { render :show, status: :ok, location: @merged_scorecard }
      else
        format.html { render :edit }
        format.json { render json: @merged_scorecard.errors, status: :unprocessable_entity }
      end
    end 
  end
  
  
  def content_subtitle
    return @scorecard.name if @scorecard.present?
    super
  end

  private

    def set_scorecard
      @scorecard = current_account.scorecards.find(params[:id])
      authorize @scorecard
    end
    
    def set_active_tab
      @active_tab = params.dig(:active_tab)&.to_sym || :scorecard
    end

    def scorecard_params
      params.require(:scorecard).permit(
        :name, 
        :description, 
        :wicked_problem_id,
        :community_id,
        initiatives_attributes: [
          :_destroy,
          :name,
          :description,
          :scorecard_id,
          :started_at,
          :finished_at,
          :dates_confirmed,
          :contact_name,
          :contact_email,
          :contact_phone,
          :contact_website,
          :contact_position,
          initiatives_organisations_attributes: [
            :_destroy,
            :organisation_id
          ]
        ]
      )
    end
end