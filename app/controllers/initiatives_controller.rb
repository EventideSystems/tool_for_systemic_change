class InitiativesController < ApplicationController
  before_action :set_initiative, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Initiatives", :initiatives_path
  
  def index
    @initiatives = policy_scope(Initiative).order(sort_order).page params[:page]
  end

  def show
    @grouped_checklist_items = @initiative.checklist_items_ordered_by_ordered_focus_area
    add_breadcrumb @initiative.name
  end

  def new
    @scorecard = params[:scorecard_id].present? ? policy_scope(Scorecard).find(params[:scorecard_id]) : nil
    @initiative = Initiative.new(scorecard: @scorecard)
    authorize @initiative
    add_breadcrumb 'New Initiative'
  end

  def edit
    add_breadcrumb @initiative.name
  end
  
  def edit_checklist_item_comment
    
  end
  
  def update_checklist_item_comment
    
  end

  def create
    @initiative = Initiative.new(initiative_params)
    authorize @initiative
    
    respond_to do |format|
      if @initiative.save
        format.html { redirect_to initiatives_path, notice: 'Initiative was successfully created.' }
        format.json { render :show, status: :created, location: @initiative }
      else
        format.html { render :new }
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @initiative.update(initiative_params)
        format.html { redirect_to initiatives_path, notice: 'Initiative was successfully updated.' }
        format.json { render :show, status: :ok, location: @initiative }
      else
        format.html { render :edit }
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @initiative.destroy
    respond_to do |format|
      format.html { redirect_to initiatives_url, notice: 'Initiative was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_initiative
      @initiative = Initiative.find(params[:id])
      authorize @initiative
    end

    def initiative_params
      params.fetch(:initiative, {}).permit(
        :name,
        :description,
        :scorecard_id,
        :started_at,
        :finished_at,
        :dates_confirmed,
        :contact_name,
        :contact_email,
        :contact_phone,
        :contact_website,
        :contact_position,
        initiatives_organisations_attributes: [
          :organisation_id, :id, :_destroy
        ]
      )
    end
end
