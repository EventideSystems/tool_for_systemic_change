class FocusAreaGroupsController < AuthenticatedController
  before_action :set_focus_area_group, only: [:show]

  # GET /focus_area_groups
  # GET /focus_area_groups.json
  def index
    @focus_area_groups = FocusAreaGroup.all

    render json: @focus_area_groups, include: ['focusAreas', 'focusAreas.characteristics']
  end

  # GET /focus_area_groups/1
  # GET /focus_area_groups/1.json
  def show
    render json: @focus_area_group, include: ['focusAreas', 'focusAreas.characteristics']
  end

  private

  def set_focus_area_group
    @focus_area_group = FocusAreaGroup.find(params[:id])
  end

end
