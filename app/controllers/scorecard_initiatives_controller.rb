class ScorecardInitiativesController < AuthenticatedController

  before_action :set_scorecard, only: [:show]
  before_action :set_scorecard_from_shared, only: [:index]

  skip_before_filter :authenticate_user!, only: :index
  skip_before_filter :authorize_client!, only: :index

  class InvalidSharedLinkId < Exception; end

  resource_description do
    formats ['json']
  end

  api :GET, '/scorecards/:scorecord_id/initiatives'
  def index
    @initiatives = @scorecard.initiatives.includes(
      :organisations,
      :checklist_items,
      characteristics: [ :video_tutorials, focus_area: [:video_tutorials, :focus_area_group] ]
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

    def set_scorecard_from_shared
      if /\A\d+\z/ =~ params[:scorecard_id] # param[:scorecard_id] is an integer
        set_scorecard
      else
        @scorecard = Scorecard.find_by(shared_link_id: params[:scorecard_id])
        raise InvalidSharedLinkId, 'Unknown shared link id' unless @scorecard
        raise Client::NotAuthorized.new("Client account has been deactivated") unless @scorecard.client.active?
      end
    end

end
