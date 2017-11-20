class DashboardController < ApplicationController
  
  skip_after_action :verify_policy_scoped
  
  def index
    add_breadcrumb "Dashboard"
    
    flash[:alert] = "Select an account before continuing." unless current_account.present?
    
    @scorecard_count = policy_scope(Scorecard).all.count
    @initiative_count = policy_scope(Initiative).all.count
    @wicked_problem_count = policy_scope(WickedProblem).all.count
    @organisation_count = policy_scope(Organisation).all.count
    
    @video_tutorials = policy_scope(VideoTutorial).promoted_to_dashboard.all

    @welcome_message = current_account.present? ? current_account.welcome_message : ''
    @recent_versions = current_account.present? ? policy_scope(PaperTrail::Version).limit(10).order(created_at: :desc) : []
  end
end