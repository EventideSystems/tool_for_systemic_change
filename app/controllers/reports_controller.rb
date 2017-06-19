class ReportsController < ApplicationController
  
  skip_after_action :verify_policy_scoped
 # skip_after_action :verify_authorized

  add_breadcrumb "Reports", :reports_path
  
  def index
    authorize :report, :index?
  end

  def initiatives
    authorize :report, :index? # SMELL Incorrect policy check. Need to fix.
    
    @content_subtitle = 'Initiatives'
    add_breadcrumb @content_subtitle
     
    query = policy_scope(Initiative).joins(scorecard: [:community, :wicked_problem])

    wicked_problem_ids = params[:report][:wicked_problems].reject { |e| e.to_s.empty? }
    community_ids = params[:report][:communities].reject { |e| e.to_s.empty? }
    
    if wicked_problem_ids
      query = query.where('scorecards.wicked_problem_id' => wicked_problem_ids)
    end

    if community_ids
      query = query.where('scorecards.community_id' => community_ids)
    end

    @results = query.select(
      :id, 
      :name, 
      :description,
      :created_at,
      :scorecard_id,
      'wicked_problems.name as wicked_problem_name', 
      'communities.name as community_name', 
      'scorecards.name as scorecard_name'
    ).distinct.page params[:page]
  end

  def stakeholders
    authorize :report, :index?
    
    @content_subtitle = 'Stakeholders'
    add_breadcrumb @content_subtitle
    
    query = current_account.organisations.joins(:sector, initiatives: [scorecard: [:wicked_problem, :community]])

    if !params[:report][:sector].blank?
      query = query.where(sector_id: params[:report][:sector])
    end

    if !params[:report][:wicked_problem].blank?
      query = query.where('scorecards.wicked_problem_id' => params[:report][:wicked_problem])
    end

    if !params[:report][:community].blank?
      query = query.where('scorecards.community_id' => params[:report][:community])
    end

    @results = query.select(
      :id, 
      :name, 
      :description,
      :created_at,
      :sector_id,
      'sectors.name as sector_name',
      'wicked_problems.name as wicked_problem_name',
      'initiatives.name as initiative_name',  
      'communities.name as community_name', 
      'scorecards.name as scorecard_name'
    ).distinct.page params[:page]
  end
  
  def scorecard_activity
    authorize :report, :index?
    
    @content_subtitle = 'Scorecard Activity'
    add_breadcrumb @content_subtitle

    @date_from = Date.parse(params[:report][:date_from])
    @date_to = Date.parse(params[:report][:date_to])
    @scorecard = current_account.scorecards.find(params[:report][:scorecard_id])
    


    @report = Reports::ScorecardActivity.new(@scorecard, @date_from, @date_to)

    respond_to do |format|
      format.html
      format.csv do
        filename = 'scorecard_activity'
        send_data @report.to_csv, :type => Mime[:csv], :filename =>"#{filename}.csv" 
      end
    end
  end
  
  def scorecard_comments
    authorize :report, :index?
    
    @content_subtitle = 'Scorecard Comments'
    add_breadcrumb @content_subtitle
    
    @scorecard = current_account.scorecards.find(params[:report][:scorecard_id])
    @date = Date.parse(params[:report][:date])
    
    @report = Reports::ScorecardComments.new(@scorecard, @date)

    respond_to do |format|
      format.html
      format.csv do
        filename = 'scorecard_comments'
        send_data @report.to_csv, :type => Mime[:csv], :filename =>"#{filename}.csv" 
      end
    end
  end
  
     
end