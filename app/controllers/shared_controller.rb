# frozen_string_literal: true

class SharedController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  def show
    response.headers.delete 'X-Frame-Options'

    load_scorecard_and_supporting_data

    if @scorecard.present?
      if params[:iframe] == 'true'
        render 'show_iframe', layout: false
      else
        render layout: 'embedded'
      end

    else
      render file: 'public/404.html', layout: 'embedded', status: :not_found
    end
  end

  # SMELL: Duplicate of code in scorecards_controller.rb
  def targets_network_map
    @scorecard = Scorecard.find_by_shared_link_id(params[:id])

    respond_to do |format|
      format.json do
        data = EcosystemMaps::TargetsNetwork.new(@scorecard)
        render json: { data: { nodes: data.nodes, links: data.links } }
      end
    end
  end

  private

  def load_scorecard_and_supporting_data
    @scorecard = Scorecard.find_by_shared_link_id(params[:id])

    return if @scorecard.blank?

    @results = ScorecardGrid.execute(@scorecard, nil, [])
    @focus_areas = FocusArea.per_scorecard_type(@scorecard.type).ordered_by_group_position
    @characteristics = Characteristic.per_scorecard_type(@scorecard.type).includes(focus_area: :focus_area_group).order('focus_areas.position, characteristics.position')
  end
end
