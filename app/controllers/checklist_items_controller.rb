class ChecklistItemsController < AuthenticatedController
  before_action :set_initiative
  before_action :set_checklist_item, only: [:show, :update]

  resource_description do
    short 'Checklist Item'
    formats ['json']

  end

  api :GET, '/initiative/:initiative_id/checklist_items'
  param :initiative_id, :number, required: true
  example  <<-EOS
  {"data" =>
    [{"id" => "18937",
      "type" => "checklist_items",
      "attributes" => {"checked" => nil, "comment" => nil},
      "relationships" => {"initiative" => {"data" => {"type" => "initiatives", "id" => "527"}}, "characteristic" => {"data" => {"type" => "characteristics", "id" => "5941"}}}},
     {"id" => "18938",
      "type" => "checklist_items",
      "attributes" => {"checked" => nil, "comment" => nil},
      "relationships" => {"initiative" => {"data" => {"type" => "initiatives", "id" => "527"}}, "characteristic" => {"data" => {"type" => "characteristics", "id" => "5942"}}}},

      ... other checklist items

     {"id" => "18972",
      "type" => "checklist_items",
      "attributes" => {"checked" => nil, "comment" => nil},
      "relationships" => {"initiative" => {"data" => {"type" => "initiatives", "id" => "527"}}, "characteristic" => {"data" => {"type" => "characteristics", "id" => "5976"}}}}],
   "included" =>
    [{"id" => "5941",
      "type" => "characteristics",
      "attributes" => {"name" => "highlight the need to organise communities differently"},
      "relationships" => {"focusArea" => {"data" => {"type" => "focus_areas", "id" => "1486"}}}},

      ... other characteristics

     {"id" => "1486",
      "type" => "focus_areas",
      "attributes" => {"name" => "create! a disequilibrium state", "description" => nil},
      "relationships" =>
       {"focusAreaGroup" => {"data" => {"type" => "focus_area_groups", "id" => "496"}},
        "characteristics" =>
         {"data" =>
           [{"type" => "characteristics", "id" => "5941"},
             ... other focus areas
            {"type" => "characteristics", "id" => "5948"}]}}},
     {"id" => "496",
      "type" => "focus_area_groups",
      "attributes" => {"name" => "Unlock Complex Adaptive System Dynamics", "description" => nil},
      "relationships" =>
       {"focusAreas" =>
         {"data" =>
           [{"type" => "focus_areas", "id" => "1486"},
             ...
            {"type" => "focus_areas", "id" => "1490"}]}}}

      ... other characteristics, focus areas and focus area groups
    ]
  }
  EOS
  def index
    @intiative_checklist_items = @intiative.checklist_items

    render json: @intiative_checklist_items, include: ['characteristic', 'characteristic.focusArea', 'characteristic.focusArea.focusAreaGroup']
  end

  api :GET, '/initiative/:initiative_id/checklist_items/:id'
  param :initiative_id, :number, required: true
  param :id, :number, required: true
  def show
    render json: @intiative_checklist_item, include: ['characteristic', 'characteristic.focusArea', 'characteristic.focusArea.focusAreaGroup']
  end

  api :PUT, '/initiative/:initiative_id/checklist_items/:id'
  api :PATCH, '/initiative/:initiative_id/checklist_items/:id'
  param :initiative_id, :number, required: true
  param :id, :number, required: true
  # {"checked"=>"true", "comment"=>"reiciendis omnis aut"}
  def update
    attributes = normalize(checklist_item_params)
    respond_to do |format|
      if @intiative_checklist_item.update(attributes)
        format.json { render json: { status: :ok, location: @intiative_checklist_item } }
      else
        format.json { render json: @intiative_checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  api :PUT, '/initiative/:initiative_id/checklist_items/'
  api :PATCH, '/initiative/:initiative_id/checklist_items/'
  param :data, Array do
    param :id, :number
    param :attributes, Hash do
      param :checked, :bool
      param :comment, String
    end
  end
  example <<-EOS
  {"data"=>
    [
      {
        "id"=>"18901",
        "attributes" => {"checked"=>"true", "comment"=>"illum deserunt et"}
      },
     {
       "id"=>"18902",
       "attributes" => {"checked"=>"true", "comment"=>"numquam rerum labore"}
     }
   ]
  }
  EOS
  def bulk_update
    success = false

    params[:data].map do |checklist_item_params|
      intiative_checklist_item = @intiative.checklist_items.find(checklist_item_params[:id])

      attributes = bulk_checklist_item_params(
        normalize(checklist_item_params)
      )

      success = intiative_checklist_item.update(attributes)
    end

    respond_to do |format|
      if success
        format.json { render json: { status: :ok, location: @intiative } } # SMELL route to initiative/:initiative_id/checklist_items
      else
        format.json { render json: @intiative.errors, status: :unprocessable_entity } # SMELL errors for initiative/:initiative_id/checklist_items
      end
    end
  end

  private

    def set_initiative
      @intiative = current_client.initiatives.find(params[:initiative_id])
    rescue ActiveRecord::RecordNotFound
      raise User::NotAuthorized
    end

    def set_checklist_item
      @intiative_checklist_item = @intiative.checklist_items.find(params[:id])
    end

    def checklist_item_params
      params.require(:data).permit(attributes: [:checked, :comment])
    end

    def bulk_checklist_item_params(checklist_item_params)
      checklist_item_params.permit(:checked, :comment)
    end

end
