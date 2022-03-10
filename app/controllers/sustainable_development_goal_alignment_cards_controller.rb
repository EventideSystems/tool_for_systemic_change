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

      format.html do

      end
    end
  end

  def scorecard_class_name
    'SustainableDevelopmentGoalAlignmentCard'
  end

  def content_title
    'SDG Alignment Cards'
  end

  def scorecard_key_param
    :sustainable_development_goal_alignment_card
  end
end
