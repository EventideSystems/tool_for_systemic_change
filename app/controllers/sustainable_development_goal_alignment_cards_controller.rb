# frozen_string_literal: true

class SustainableDevelopmentGoalAlignmentCardsController < ScorecardsController
  def index
    @scorecards = policy_scope(Scorecard)
                  .where(type: 'SustainableDevelopmentGoalAlignmentCard')
                  .order(sort_order).page params[:page]
  end

  def targets_network_map
    @scorecard = current_account.scorecards.find(params[:id])
    authorize @scorecard

    respond_to do |format|
      format.json do
        data = EcosystemMaps::TargetsNetwork.new(@scorecard)
        render json: { data: { nodes: data.nodes, links: data.links } }
      end
    end
  end

  def characteristic
    @scorecard = current_account.scorecards.find(params[:sustainable_development_goal_alignment_card_id])
    authorize @scorecard

    @characteristic = Characteristic.find(params[:id])

    checklist_items = \
      ChecklistItem
      .where(characteristic: @characteristic, initiative: @scorecard.initiatives)
      .includes(:checklist_item_comments)
      .select { |item| item.current_comment_status == 'actual' }

    @initiatives = checklist_items.map(&:initiative).sort_by(&:name)

    @targets = TargetsNetworkMapping.where(characteristic: @characteristic).map(&:focus_area).uniq.sort_by(&:name)

    render 'sustainable_development_goal_alignment_cards/show_tabs/characteristics/show', layout: false
  end

  def scorecard_class_name
    'SustainableDevelopmentGoalAlignmentCard'
  end

  def content_title
    SustainableDevelopmentGoalAlignmentCard.model_name.human.pluralize
  end

  def scorecard_key_param
    :sustainable_development_goal_alignment_card
  end
end
