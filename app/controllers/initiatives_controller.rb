class InitiativesController < ApplicationController
  before_action :set_initiative, only: [:show, :edit, :update, :destroy]

  def index
    @initiatives = policy_scope(Initiative).page params[:page]
  end

  def show
    @grouped_checklist_items = @initiative.checklist_items_ordered_by_ordered_focus_area
  end

  def new
    @initiative = Initiative.new
    authorize @initiative
  end

  def edit
  end

  def create
    @initiative = Initiative.new(initiative_params)
    authorize @initiative
    
    respond_to do |format|
      if @initiative.save
        format.html { redirect_to @initiative, notice: 'Initiative was successfully created.' }
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
        format.html { redirect_to @initiative, notice: 'Initiative was successfully updated.' }
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

    # def grouped_checklist_items(initiative)
    #   checklist_items = initiative.checklist_items.includes(characteristic: [focus_area: :focus_area_group])
    #     .order('focus_area_groups.position', 'focus_areas.position', 'characteristics.position')
    #
    #   checklist_items_by_focus_area = checklist_items.group_by { |ci| ci.characteristic.focus_area }
    #   checklist_items_by_focus_area_group = checklist_items_by_focus_area.group_by do |fa|
    #     fa.first.focus_area_group
    #   end
    #
    #   checklist_items_by_focus_area_group
    # end
    
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
          :organisation_id, :id
        ]
      )
    end
end
