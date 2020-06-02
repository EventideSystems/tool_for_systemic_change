class ScorecardsController < ApplicationController
  before_action :set_scorecard, only: [:show, :edit, :update, :destroy, :show_shared_link, :copy, :copy_options, :merge, :merge_options] 
  before_action :set_active_tab, only: [:show] 
  before_action :require_account_selected, only: [:new, :create, :edit, :update, :show_shared_link] 

  add_breadcrumb Scorecard.model_name.human.pluralize, :scorecards_path
  
  def index
    @scorecards = policy_scope(Scorecard).order(sort_order).page params[:page]
  end

  def show
    @selected_date = params[:selected_date]
    @parsed_selected_date = @selected_date.blank? ? nil : Date.parse(@selected_date)
    
    @selected_tags = params[:selected_tags].blank? ? [] : SubsystemTag.where(account: current_account, name: params[:selected_tags])
    
    @focus_areas = FocusArea.ordered_by_group_position
    
    @initiatives = if @parsed_selected_date.present? 
      @scorecard.initiatives
        .where('started_at <= ? OR started_at IS NULL', @parsed_selected_date)
        .where('finished_at >= ? OR finished_at IS NULL', @parsed_selected_date)
        .order(name: :asc)
    else  
      @scorecard.initiatives.order(name: :asc)
    end
    
    @initiatives = if @selected_tags.present?
      tag_ids = @selected_tags.map(&:id)
      @initiatives
        .distinct
        .joins(:initiatives_subsystem_tags)
        .where('initiatives_subsystem_tags.subsystem_tag_id' => tag_ids)
        .select('initiatives.*, lower(initiatives.name)')
    else 
      @initiatives
    end

    link_data = load_link_data(@scorecard)
    @nodes = load_nodes(link_data)
    @links = load_links(link_data)
      
    add_breadcrumb @scorecard.name
    
    respond_to do |format|
      format.html 
      format.pdf do
        pdf = ScorecardPdfGenerator.new(
          scorecard: @scorecard, 
          initiatives: @initiatives, 
          focus_areas: @focus_areas
        ).perform
        send_data pdf.render,
          filename: "transition_card_#{@scorecard.id}.pdf",
          type: 'application/pdf',
          disposition: 'inline'
      end 
    end
  end

  def new
    @scorecard = current_account.scorecards.build
    authorize @scorecard
    @scorecard.initiatives.build
   # @scorecard.initiatives.first.initiatives_organisations.build
    add_breadcrumb "New"
  end

  def edit
    add_breadcrumb @scorecard.name
  end

  def create
    @scorecard = current_account.scorecards.build(scorecard_params)
    authorize @scorecard

    respond_to do |format|
      if @scorecard.save
        format.html { redirect_to scorecard_path(@scorecard), notice: "#{Scorecard.model_name.human} was successfully created." }
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
        format.html { redirect_to @scorecard, notice: "#{Scorecard.model_name.human} was successfully updated." }
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
      format.html { redirect_to scorecards_url, notice: "#{Scorecard.model_name.human} was successfully destroyed." }
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
    deep_copy = params.dig(:copy) == 'deep' 

    @copied_scorecard = ScorecardCopier.new(@scorecard, new_name, deep_copy: deep_copy).perform
    respond_to do |format|
      if @copied_scorecard.present?
        format.html { redirect_to scorecard_path(@copied_scorecard), notice: "#{Scorecard.model_name.human} was successfully copied." }
        format.json { render :show, status: :ok, location: @copied_scorecard }
      else
        format.html { render :edit }
        format.json { render json: @copied_scorecard.errors, status: :unprocessable_entity }
      end
    end 
  end
  
  def merge_options
    @other_scorecards = current_account.scorecards.where.not(id: @scorecard.id).order('lower(name)')
    render layout: false
  end
  
  def merge
    @other_scorecard = current_account.scorecards.find(params[:other_scorecard_id])
    @merged_scorecard = @scorecard.merge(@other_scorecard)
    respond_to do |format|
      if @scorecard.present?
        format.html { redirect_to scorecard_path(@merged_scorecard), notice: "#{Scorecard.model_name.human} were successfully merged." }
        format.json { render :show, status: :ok, location: @merged_scorecard }
      else
        format.html { render :edit }
        format.json { render json: @merged_scorecard.errors, status: :unprocessable_entity }
      end
    end 
  end
  
  def content_title
    Scorecard.model_name.human.pluralize
  end
  
  def content_subtitle
    return @scorecard.name if @scorecard.present?
    super
  end

  private

  def load_nodes(link_data)
    level = 0
    current_account.organisations.where(id: link_data.flatten.uniq).map do |org|
      level += 1
      level = 0 if level > 1 
      { id: org.id, group: 0, label: org.name.truncate(20), level: level }
    end.to_json
  end

  def load_links(link_data)
    link_data.map do |row|
      { target: row[0], source: row[1], strength: 0.1 }
    end.to_json
  end

  def load_link_data(scorecard)
    query = <<~SQL
      select org1.id, org2.id from initiatives
      inner join scorecards on scorecards.id = initiatives.scorecard_id
      inner join initiatives_organisations io1 on io1.initiative_id = initiatives.id
      inner join organisations org1 on org1.id = io1.organisation_id
      inner join initiatives_organisations io2 on io2.initiative_id = initiatives.id
      inner join organisations org2 on org2.id = io2.organisation_id
      where org1.id <> org2.id and initiatives.scorecard_id = #{scorecard.id};
    SQL

    results = ActiveRecord::Base.connection.exec_query(query).rows

    (results + results.map{ |r| [r[1], r[0]] }).uniq
  end


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
          ],
          initiatives_subsystem_tags_attributes: [
            :_destroy,
            :subsystem_tag_id
          ]
        ]
      ).tap do |params| # NOTE Dupe of code in initiatives controller
        unless params[:initiatives_attributes].blank?
          params[:initiatives_attributes].each do |initiative_key, _|
            params[:initiatives_attributes][initiative_key][:initiatives_organisations_attributes].reject! do |key, value|
              value[:_destroy] != '1' && (
                value[:organisation_id].blank? || (
                  value[:id].blank? && 
                  params[:initiatives_attributes][initiative_key][:initiatives_organisations_attributes].to_h.any? do |selected_key, selected_value|
                    selected_key != key &&
                    selected_value[:_destroy] != '1' && 
                    selected_value[:organisation_id] == value[:organisation_id]
                  end
                )
              )
            end  
          end
        end
        
        unless params[:initiatives_attributes].blank?
          params[:initiatives_attributes].each do |initiative_key, _|
            params[:initiatives_attributes][initiative_key][:initiatives_subsystem_tags_attributes].reject! do |key, value|
              value[:_destroy] != '1' && (
                value[:subsystem_tag_id].blank? || (
                  value[:id].blank? && 
                  params[:initiatives_attributes][initiative_key][:initiatives_subsystem_tags_attributes].to_h.any? do |selected_key, selected_value|
                    selected_key != key &&
                    selected_value[:_destroy] != '1' && 
                    selected_value[:subsystem_tag_id] == value[:subsystem_tag_id]
                  end
                )
              )
            end  
          end
        end
      end
    end
end
