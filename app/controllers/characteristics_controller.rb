class CharacteristicsController < AuthenticatedController
  before_action :set_characteristic, only: [:show]

  # GET /characteristics
  # GET /characteristics.json
  def index
    @characteristics = Characteristic.all

    render json: @characteristics, include: ['focusArea', 'focusArea.focusAreaGroup']
  end

  # GET /characteristics/1
  # GET /characteristics/1.json
  def show
    render json: @characteristic, include: ['focusArea', 'focusArea.focusAreaGroup']
  end

  private

  def set_characteristic
    # SMELL
    @characteristic = Characteristic.find(params[:id]) rescue (raise User::NotAuthorized )
  end

end
