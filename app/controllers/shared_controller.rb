class SharedController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized
  
  def show
    @focus_areas = FocusArea.ordered_by_group_position
    @scorecard = Scorecard.find_by_shared_link_id(params[:id])
    if params[:iframe] == 'true'
      response.headers.delete "X-Frame-Options"
      render 'show_iframe', layout: false
    else
      render layout: 'embedded'
    end
  end
end