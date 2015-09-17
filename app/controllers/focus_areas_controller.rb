class FocusAreasController < AuthenticatedController
  before_action :set_focus_area, only: [:show]

  # GET /focus_areas
  # GET /focus_areas.json
  def index
    @focus_areas = FocusArea.all

    render json: @focus_areas, include: ['characteristics', 'focusAreaGroup']
  end

  # GET /focus_areas/1
  # GET /focus_areas/1.json
  def show
    render json: @focus_area, include: ['characteristics', 'focus_area_group']
  end

  private

  def set_focus_area
    # SMELL
    @focus_area = FocusArea.find(params[:id]) rescue (raise User::NotAuthorized )
  end

end
