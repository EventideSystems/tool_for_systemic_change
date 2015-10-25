class FocusAreasController < AuthenticatedController
  before_action :set_focus_area, only: [:show, :video_tutorial_embedded_iframe]

  resource_description do
    formats ['json']
  end

  api :GET, '/focus_areas'
  def index
    @focus_areas = FocusArea.all

    render json: @focus_areas,
      include: ['characteristics', 'focusAreaGroup'],
      each_serializer: FocusAreaWithCharacteristicsSerializer
  end

  api :GET, '/focus_areas/:id'
  param :id, :number, required: true
  def show
    render json: @focus_area,
      include: ['characteristics', 'focusAreaGroup'],
      serializer: FocusAreaWithCharacteristicsSerializer
  end

  def video_tutorial_embedded_iframe
    render json: @focus_area, serializer: VideoTutorialEmbeddedIframeSerializer
  end

  private

  def set_focus_area
    # SMELL
    @focus_area = FocusArea.find(params[:id]) rescue (raise User::NotAuthorized )
  end

end
