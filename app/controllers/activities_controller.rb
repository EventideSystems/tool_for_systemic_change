class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  
  add_breadcrumb "Activities", :activities_path
  
  def index
    @activities = policy_scope(PublicActivity::Activity).order(sort_order).page params[:page]
  end

end
