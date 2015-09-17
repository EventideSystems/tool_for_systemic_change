class FocusAreaGroupsController < AuthenticatedController
  before_action :set_focus_area_group, only: [:show]

  # GET /communities
  # GET /communities.json
  def index
    @focus_area_groups = FocusAreaGroup.all

    render json: @focus_area_groups, include: ['focus_areas']
  end

  # GET /communities/1
  # GET /communities/1.json
  def show
    render json: @focus_area_group, include: ['focus_areas']
  end

  private

  def set_focus_area_group
    # SMELL
    @focus_area_group = FocusAreaGroup.find(params[:id]) rescue (raise User::NotAuthorized )
  end

end
