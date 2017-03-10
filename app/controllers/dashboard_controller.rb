class DashboardController < ApplicationController
  
  skip_after_action :verify_policy_scoped
  
  def index
    add_breadcrumb "Dashboard"
    @scorecard_count = policy_scope(Scorecard).all.count
    @initiative_count = policy_scope(Initiative).all.count
    @complete_initiatives_count = policy_scope(Initiative).complete.count
    @incomplete_initiatives_count = policy_scope(Initiative).incomplete.count
    @overdue_initiatives_count = policy_scope(Initiative).overdue.count
    @welcome_message = current_account.welcome_message
    @recent_activities = policy_scope(PublicActivity::Activity).limit(10).order(created_at: :desc)
  end
end
