# frozen_string_literal: true

class SharedController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  def show
    response.headers.delete 'X-Frame-Options'

    load_scorecard_and_results

    if @scorecard.present?
      @focus_areas = FocusArea.ordered_by_group_position
      @characteristics = Characteristic.includes(focus_area: :focus_area_group).order('focus_areas.position, characteristics.position')
    end

    if params[:iframe] == 'true'
      render 'show_iframe', layout: false
    else
      render layout: 'embedded'
    end
  end

  private

  def load_scorecard_and_results
    @scorecard = Scorecard.find_by_shared_link_id(params[:id])
    @results = ScorecardGrid.execute(@scorecard, nil, []) if @scorecard.present?
  end
end
