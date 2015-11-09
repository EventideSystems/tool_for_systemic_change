class ActivitiesController < AuthenticatedController
  before_action :check_trackable_type

  class UnpermittedTrackableType < Exception; end

  rescue_from UnpermittedTrackableType do |exception|
    render json: { errors: exception.message }, status: 400
  end

  def index
    query = PublicActivity::Activity.
            where(client_id: current_client_id).
            order(created_at: :desc)

    if params[:user_id]
      query = query.where(owner_type: "User", owner_id: params[:user_id])
    end

    if params[:trackable_type]
      query = query.where(trackable_type: params[:trackable_type])
    end

    if params[:trackable_id]
      query = query.where(trackable_id: params[:trackable_id])
    end

    @activities = finder_for_pagination(query).all

    render json: @activities, each_serializer: ActivitySerializer
  end

  private

  TRACKABLE_TYPES = %w(
    ChecklistItem
    Community
    Initiative
    Organisation
    Scorecard
    Sector
    User
    WickedProblem
  )

  def check_trackable_type
    if params[:trackable_type]
      unless TRACKABLE_TYPES.include?(params[:trackable_type])
        raise UnpermittedTrackableType,
              "Unpermitted trackable type '#{params[:trackable_type]}'"
      end
    end
  end
end
