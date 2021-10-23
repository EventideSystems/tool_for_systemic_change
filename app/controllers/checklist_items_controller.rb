class ChecklistItemsController < ApplicationController
  before_action :set_initiative
  before_action :set_checklist_item, 
    only: [:show, :edit, :update, :update_comment, :create_comment, :destroy]
  before_action :require_account_selected
  
  # GET /checklist_items
  # GET /checklist_items.json
  def index
    @checklist_items = policy_scope(ChecklistItem).where(initiative_id: @initiative.id).all
  end

  # GET /checklist_items/1
  # GET /checklist_items/1.json
  def show
  end

  # GET /checklist_items/new
  def new
    @checklist_item = @initiative.checklist_items.build
    authorize @intiative
  end

  # GET /checklist_items/1/edit
  def edit
  end

  # POST /checklist_items
  # POST /checklist_items.json
  def create
    @checklist_item = @initiative.checklist_items.build(checklist_item_params)
    authorize @intiative
    
    respond_to do |format|
      if @checklist_item.save
        format.html { redirect_to @checklist_item, notice: 'Checklist item was successfully created.' }
        format.json { render :show, status: :created, location: @checklist_item }
      else
        format.html { render :new }
        format.json { render json: @checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checklist_items/1
  # PATCH/PUT /checklist_items/1.json
  def update
    respond_to do |format|
      if @checklist_item.update(checklist_item_params)
        format.html { redirect_to @checklist_item, notice: 'Checklist item was successfully updated.' }
        # format.json { render :show, status: :ok, location: @checklist_item }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @checklist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_comment
    case params[:commit]
    when "Update Existing"
      return if params.dig(:checklist_item, :current_comment).blank?
 
      @checklist_item.update_attribute(
        :checked, 
        params.dig(:checklist_item, :current_comment_status).in?(['actual', 'planned'])
      )

      if @checklist_item.current_checklist_item_comment.blank?
        @checklist_item.checklist_item_comments.create(
          comment: params.dig(:checklist_item, :current_comment),
          status: params.dig(:checklist_item, :current_comment_status)
        )
      else
        @checklist_item.current_checklist_item_comment.update(
          comment: params.dig(:checklist_item, :current_comment),
          status: params.dig(:checklist_item, :current_comment_status)
        )
      end
    when "Save New Comment"
      return if params.dig(:checklist_item, :new_comment).blank?

      @checklist_item.update_attribute(
        :checked, 
        params.dig(:checklist_item, :new_comment_status).in?(['actual', 'planned'])
      )

      @checklist_item.checklist_item_comments.create(
        comment: params.dig(:checklist_item, :new_comment),
        status: params.dig(:checklist_item, :new_comment_status)
      )
    end
  end

  def create_comment
    return if params.dig(:checklist_item, :new_comment).blank?
  end

  # DELETE /checklist_items/1
  # DELETE /checklist_items/1.json
  def destroy
    @checklist_item.destroy
    respond_to do |format|
      format.html { redirect_to checklist_items_url, notice: 'Checklist item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def content_subtitle
    return @checklist_item.name if @checklist_item.present?
    super
  end

  private
    def set_initiative
      @initiative = current_account.initiatives.find(params[:initiative_id])
      #authorize @intiative
    end

    def set_checklist_item
      @checklist_item = @initiative.checklist_items.find(params[:id])
      authorize @checklist_item
    end

    def bulk_checklist_item_params(checklist_item_params)
      checklist_item_params.permit(:checked, :comment)
    end
  
    def checklist_item_params
      params.require(:checklist_item).permit(:checked, :comment)
    end
    
end
