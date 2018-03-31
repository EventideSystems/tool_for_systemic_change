class SharedController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized
  
  layout 'embedded'
  
  def show
    @focus_areas = FocusArea.ordered_by_group_position
    @scorecard = Scorecard.find_by_shared_link_id(params[:id])
    if params[:iframe] == 'true'
      render 'show_iframe', layout: 'embedded'
    else
      render layout: 'embedded'
    end
  end
end