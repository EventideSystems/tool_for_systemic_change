class ActivitiesController < ApplicationController
  
  def index
    @activities = policy_scope(PublicActivity::Activity).page params[:page]
  end

end
