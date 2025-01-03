# frozen_string_literal: true

# Controller for managing shared impact cards
class SharedController < ApplicationController
  def show # rubocop:disable Metrics/MethodLength
    response.headers.delete('X-Frame-Options')

    load_scorecard_and_supporting_data

    if @scorecard.present?
      if params[:iframe] == 'true'
        render('show_iframe', layout: false)
      else
        render(layout: 'embedded')
      end

    else
      render(file: 'public/404.html', layout: 'embedded', status: :not_found)
    end
  end

  def characteristic # rubocop:disable Metrics/AbcSize
    @scorecard = Scorecard.find_by(shared_link_id: params[:shared_id])

    @characteristic = Characteristic.find(params[:id])

    checklist_items =
      ChecklistItem
      .where(characteristic: @characteristic, initiative: @scorecard.initiatives)
      .includes(:checklist_item_comments)
      .select { |item| item.status == 'actual' }

    @initiatives = checklist_items.map(&:initiative).sort_by(&:name)

    @targets = TargetsNetworkMapping.where(characteristic: @characteristic).map(&:focus_area).uniq.sort_by(&:name)

    render('sustainable_development_goal_alignment_cards/show_tabs/characteristics/show', layout: false)
  end

  # SMELL: Duplicate of code in scorecards_controller.rb
  def targets_network_map
    @scorecard = Scorecard.find_by(shared_link_id: params[:id])

    respond_to do |format|
      format.json do
        data = EcosystemMaps::TargetsNetwork.new(@scorecard)
        render(json: { data: { nodes: data.nodes, links: data.links } })
      end
    end
  end

  private

  def load_scorecard_and_supporting_data # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @scorecard = Scorecard.find_by(shared_link_id: params[:id])

    return if @scorecard.blank?

    @initiatives = @scorecard.initiatives.order(:name)
    @organisations = @initiatives.filter_map(&:organisations).flatten.uniq.sort_by(&:name)

    @results = ScorecardGrid.execute(@scorecard, nil, [])
    @focus_areas = FocusArea.per_scorecard_type_for_account(
      @scorecard.type,
      @scorecard.account
    ).ordered_by_group_position

    @characteristics = Characteristic.per_scorecard_type_for_account(
      @scorecard.type,
      @scorecard.account
    ).includes(focus_area: :focus_area_group).order('focus_areas.position, characteristics.position')
  end
end
