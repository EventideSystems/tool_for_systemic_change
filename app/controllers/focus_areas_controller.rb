class FocusAreasController < AuthenticatedController
  before_action :set_focus_area, only: [:show, :video_tutorial]

  resource_description do
    formats ['json']
  end

  api :GET, '/focus_areas'
  def index
    @focus_areas = FocusArea.includes(:video_tutorials, :focus_area_group, { characteristics: :video_tutorials }).all

    render json: @focus_areas,
      include: ['videoTutorials', 'characteristics', 'focusAreaGroup'],
      each_serializer: FocusAreaWithCharacteristicsSerializer
  end

  api :GET, '/focus_areas/:id'
  param :id, :number, required: true
  def show
    render json: @focus_area,
      include: ['characteristics', 'focusAreaGroup'],
      serializer: FocusAreaWithCharacteristicsSerializer
  end

  def video_tutorial
    @video_tutorial = @focus_area.video_tutorials.order(updated_at: :desc).first
    render json: @video_tutorial
  end

  private

  def set_focus_area
    # SMELL
    @focus_area = FocusArea.find(params[:id]) rescue (raise User::NotAuthorized )
  end

end
