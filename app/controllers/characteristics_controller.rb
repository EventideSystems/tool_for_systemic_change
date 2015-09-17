class CharacteristicsController < AuthenticatedController
  before_action :set_characteristic, only: [:show]

  resource_description do
    formats ['json']
  end

  api :GET, '/characteristics'
  def index
    @characteristics = Characteristic.all

    render json: @characteristics, include: ['focusArea', 'focusArea.focusAreaGroup']
  end

  api :GET, '/characteristics/:id'
  param :id, :number, required: true
  example <<-EOS
  {
    "data" =>
    {
      "id" => "5365",
       "type" => "characteristics",
       "attributes" => {
         "name" => "highlight the need to organise communities differently"
       },
       "relationships" => {"focusArea" => {"data" => {"type" => "focus_areas", "id" => "1342"}}
     }
    },
   "included" =>
    [{"id" => "1342",
      "type" => "focus_areas",
      "attributes" => {"name" => "create! a disequilibrium state", "description" => nil},
      "relationships" =>
       {"focusAreaGroup" => {"data" => {"type" => "focus_area_groups", "id" => "448"}},
        "characteristics" =>
         {"data" =>
           [ .. list of related characteristics .. ]}}},
     {"id" => "448",
      "type" => "focus_area_groups",
      "attributes" => {"name" => "Unlock Complex Adaptive System Dynamics", "description" => nil},
      "relationships" =>
       {"focusAreas" =>
         {"data" =>
           [ .. list of related focus areas .. ]}}}
    ]
  }
  EOS
  def show
    render json: @characteristic, include: ['focusArea', 'focusArea.focusAreaGroup']
  end

  private

  def set_characteristic
    # SMELL
    @characteristic = Characteristic.find(params[:id]) rescue (raise User::NotAuthorized )
  end

end
