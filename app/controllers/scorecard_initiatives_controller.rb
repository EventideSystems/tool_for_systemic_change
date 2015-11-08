class ScorecardInitiativesController < AuthenticatedController

  before_action :set_scorecard, only: [:show, :index]

  resource_description do
    formats ['json']
  end

  api :GET, '/scorecards/:scorecord_id/initiatives'
  def index
    @initiatives = @scorecard.initiatives.includes(
      :organisations,
      :checklist_items,
      characteristics: { focus_area: :focus_area_group }
    ).all

    render json: @initiatives, include: [
      'checklistItems',
      'checklistItems.characteristic',
      'checklistItems.characteristic.focusArea',
      'checklistItems.characteristic.focusArea.focusAreaGroup'], each_serializer: ScorecardInitiativeSerializer
  end

  api :GET, '/scorecards/:scorecord_id/initiatives/:id'
  def show
    @initiative = @scorecard.initiatives.includes([:checklist_items])

    render json: @initiative, include: ['checklistItems', 'checklistItems.characteristic'], serializer: ScorecardInitiativeSerializer
  end

  private

    def set_scorecard
      @scorecard = current_client.scorecards.find(params[:scorecard_id])
    rescue ActiveRecord::RecordNotFound
      raise User::NotAuthorized
    end

end
