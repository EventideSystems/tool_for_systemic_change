# frozen_string_literal: true

class SharedController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  def show
    response.headers.delete 'X-Frame-Options'

    @focus_areas = FocusArea.ordered_by_group_position
    @scorecard = Scorecard.find_by_shared_link_id(params[:id])

    @results = TransitionCardSummary.execute(@scorecard, nil, [])
    @characteristics = Characteristic.includes(focus_area: :focus_area_group).order('focus_areas.position, characteristics.position')

    if params[:iframe] == 'true'
      render 'show_iframe', layout: false
    else
      render layout: 'embedded'
    end
  end
end
