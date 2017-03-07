class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  
  add_breadcrumb "Activities", :activities_path
  
  def index
    @activities = policy_scope(PublicActivity::Activity).page params[:page]
  end

end
