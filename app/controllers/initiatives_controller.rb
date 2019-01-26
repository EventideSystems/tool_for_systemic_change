class InitiativesController < ApplicationController
  before_action :set_initiative, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Initiatives", :initiatives_path
  
  def index
    respond_to do |format|
      format.html do
        @initiatives = policy_scope(Initiative).includes(:organisations).order(sort_order).page params[:page]
      end
      format.csv do
        @initiatives = policy_scope(Initiative).includes(:organisations).order(sort_order).all
        send_data initiatives_to_csv(@initiatives), :type => Mime[:csv], :filename =>"#{export_filename}.csv" 
      end
    end
  end

  def show
    @grouped_checklist_items = @initiative.checklist_items_ordered_by_ordered_focus_area
    add_breadcrumb @initiative.name
    @content_subtitle = @initiative.name
  end

  def new
    @scorecard = params[:scorecard_id].present? ? policy_scope(Scorecard).find(params[:scorecard_id]) : nil
    @initiative = Initiative.new(scorecard: @scorecard)
    authorize @initiative
    add_breadcrumb 'New Initiative'
  end

  def edit
    add_breadcrumb @initiative.name
    @content_subtitle = @initiative.name
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

  def content_subtitle
    return @initiative.name if @initiative.present?
    super
  end

  private
  
    def export_filename
      "initiatives_#{Date.today.strftime('%Y_%m_%d')}"
    end
    
    def initiatives_to_csv(initiatives)
      CSV.generate(force_quotes: true) do |csv|
        csv << [
          'Name',
          'Description',
          "#{Scorecard.model_name.human} Name",
          'Started At',
          'Finished At',
          'Contact Name',
          'Contact Email',
          'Contact Phone',
          'Contact Website',
          'Contact Position'
        ] + 1.upto(Initiatives::Import::MAX_ORGANIZATION_EXPORT).map do |index| 
          "Organisation #{index} Name" 
        end + 1.upto(Initiatives::Import::MAX_SUBSYSTEM_TAG_EXPORT).map do |index| 
          "Subsystem Tag #{index} Name" 
        end
        
        initiatives.each do |initiative|
          
          organisations = initiative.organisations.limit(Initiatives::Import::MAX_ORGANIZATION_EXPORT)
          organisation_memo = Array.new(Initiatives::Import::MAX_ORGANIZATION_EXPORT, '') 
          
          organisation_names = organisations.each_with_index.inject(organisation_memo) do |memo, (org, index)|
            memo[index] = org.try(:name)
            memo
          end
          
          subsystem_tags = initiative.subsystem_tags.limit(Initiatives::Import::MAX_SUBSYSTEM_TAG_EXPORT)
          subsystem_tag_memo = Array.new(Initiatives::Import::MAX_SUBSYSTEM_TAG_EXPORT, '') 
          
          subsystem_tag_names = subsystem_tags.each_with_index.inject(subsystem_tag_memo) do |memo, (subsystem_tag, index)|
            memo[index] = subsystem_tag.try(:name)
            memo
          end
          
          csv << [
            initiative.name,
            initiative.description,
            initiative.scorecard.try(:name),
            initiative.started_at,
            initiative.finished_at,
            initiative.contact_name,
            initiative.contact_email,
            initiative.contact_phone,
            initiative.contact_website,
            initiative.contact_position
            ] + organisation_names + subsystem_tag_names
        end
      end
    end
  
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
        ],
        initiatives_subsystem_tags_attributes: [
          :subsystem_tag_id, :id, :_destroy
        ]
      ).tap do |params|
        params[:initiatives_organisations_attributes].reject! do |key, value|
          value[:organisation_id].blank?
        end
        
        params[:initiatives_organisations_attributes].transform_values! do |value|
          value[:_destroy] = '0' if value[:_destroy] == '1' &&
            params[:initiatives_organisations_attributes].to_h.any? do |other_key, other_value|
              other_value[:_destroy] != '1' && 
              other_value[:organisation_id] == value[:organisation_id]
            end

          value
        end
        
        params[:initiatives_organisations_attributes].reject! do |key, value|
          (value[:id].nil?) &&  
          params[:initiatives_organisations_attributes].to_h.any? do |other_key, other_value|
            other_key != key && 
            other_value[:organisation_id] == value[:organisation_id]
          end
        end
      end
    end
end

 # "initiatives_organisations_attributes"=>{
 #   "0"=>{"_destroy"=>"1", "organisation_id"=>"3", "id"=>"11"},
 #   "1"=>{"organisation_id"=>"3"},
 #   "2"=>{"organisation_id"=>""}},