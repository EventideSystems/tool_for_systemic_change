class FocusAreaGroupsController < AuthenticatedController
  before_action :set_focus_area_group, only: [:show]

  resource_description do
    formats ['json']
  end

  api :GET, '/focus_area_groups'
  def index
    @focus_area_groups = FocusAreaGroup.includes(focus_areas: [:video_tutorials, characteristics: :video_tutorials]).all

    render json: @focus_area_groups,
      include: ['focusAreas', 'focusAreas.characteristics'],
      each_serializer: FocusAreaGroupWithCharacteristicsSerializer
  end

  api :GET, '/focus_area_groups/:id'
  param :id, :number, required: true
  def show
    render json: @focus_area_group,
      include: ['focusAreas', 'focusAreas.characteristics'],
      serializer: FocusAreaGroupWithCharacteristicsSerializer
  end

  private

  def set_focus_area_group
    @focus_area_group = FocusAreaGroup.find(params[:id])
  end

end
