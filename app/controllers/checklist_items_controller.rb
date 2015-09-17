class ChecklistItemsController < AuthenticatedController
  before_action :set_initiative
  before_action :set_checklist_item, only: [:show, :update]

  def index
    @intiative_checklist_items = @intiative.checklist_items

    render json: @intiative_checklist_items, include: ['characteristic', 'characteristic.focusArea', 'characteristic.focusArea.focusAreaGroup']
  end

  def show
    render json: @intiative_checklist_item, include: ['characteristic', 'characteristic.focusArea', 'characteristic.focusArea.focusAreaGroup']
  end

  def update
    attributes = normalize(checklist_item_params)
    respond_to do |format|
      if @intiative_checklist_item.update(attributes)
        format.html { redirect_to @intiative_checklist_item, notice: 'Checklist Item was successfully updated.' }
        format.json { render json: { status: :ok, location: @intiative_checklist_item } }
      else
        format.html { render :edit }
        format.json { render json: @intiative_checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

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
        format.html { redirect_to @initiative, notice: 'Checklist Item was successfully updated.' }
        format.json { render json: { status: :ok, location: @intiative } } # SMELL route to initiative/:initiative_id/checklist_items
      else
        format.html { render :edit }
        format.json { render json: @intiative.errors, status: :unprocessable_entity } # SMELL errors for initiative/:initiative_id/checklist_items
      end
    end
  end

  private

    def set_initiative
      @intiative = Initiative.for_user(current_user).find(params[:initiative_id]) rescue (raise User::NotAuthorized )
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
