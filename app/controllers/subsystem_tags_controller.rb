class SubsystemTagsController < ApplicationController
  before_action :set_subsystem_tag, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update]
  
  add_breadcrumb "Subsystem Tags", :subsystem_tags_path

  def index
    if params['q']
      @subsystem_tags = policy_scope(SubsystemTag).where("name ilike :q", q: '%' + params['q'] + '%')
    else
      @subsystem_tags = policy_scope(SubsystemTag).page(params[:page])
    end
    
    if params[:scorecard_id].present?
      @subsystem_tags = @subsystem_tags.joins(:initiatives).where('initiatives.scorecard_id' => params[:scorecard_id])
    end
  end

  def show
    add_breadcrumb @subsystem_tag.name
  end

  def new
    @subsystem_tag = current_account.subsystem_tags.build
    authorize @subsystem_tag
    add_breadcrumb "New"
  end

  def edit
    add_breadcrumb @subsystem_tag.name
  end

  def create
    @subsystem_tag = current_account.subsystem_tags.build(subsystem_tag_params)
    authorize @subsystem_tag

    respond_to do |format|
      if @subsystem_tag.save
        format.html { redirect_to @subsystem_tag, notice: 'Subsystem tag was successfully created.' }
        format.json { render :show, status: :created, location: @subsystem_tag }
        format.js
      else
        format.html { render :new }
        format.json { render json: @subsystem_tag.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @subsystem_tag.update(subsystem_tag_params)
        format.html { redirect_to @subsystem_tag, notice: 'Subsystem tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @subsystem_tag }
      else
        format.html { render :edit }
        format.json { render json: @subsystem_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @subsystem_tag.destroy
    respond_to do |format|
      format.html { redirect_to subsystem_tags_url, notice: 'Subsystem tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def content_subtitle
    return @subsystem_tag.name if @subsystem_tag.present?
    super
  end

  private

    def set_subsystem_tag
      @subsystem_tag = SubsystemTag.find(params[:id])
      authorize @subsystem_tag
    end

    def subsystem_tag_params
      params.fetch(:subsystem_tag, {}).permit(:name, :description)
    end
end
