class ReportsController < AuthenticatedController

  def initiatives
    query = Initiative.joins(:scorecard).
      where(:'scorecards.client_id' => current_client_id).
      includes(:scorecard, :organisations)

    if params[:wicked_problem_id]
      query = query.where('scorecards.wicked_problem_id' => params[:wicked_problem_id])
    end

    if params[:community_id]
      query = query.where('scorecards.community_id' => params[:community_id])
    end

    @initiatives = finder_for_pagination(query).uniq.all

    render json: @initiatives
  end

  def stakeholders
    query = Organisation.where(client_id: current_client_id).joins(:sector, initiatives: :scorecard)

    if params[:sector_id]
      query = query.where(sector_id: params[:sector_id])
    end

    if params[:wicked_problem_id]
      query = query.where('scorecards.wicked_problem_id' => params[:wicked_problem_id])
    end

    if params[:community_id]
      query = query.where('scorecards.community_id' => params[:community_id])
    end

    @organisations = finder_for_pagination(query).uniq.all

    render json: @organisations, include: ['sectors']
  end

  def density_of_effort

  end

  def emergent_initiatives

  end
end
