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
      @subsystem_tags = @subsystem_tags
        .joins(:initiatives)
        .where('initiatives.scorecard_id' => params[:scorecard_id]).distinct
    end

    respond_to do |format|
      format.html
      format.json { render json: @subsystem_tags.map { |subsystem_tag| { id: subsystem_tag.id, text: subsystem_tag.text } } }
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
        format.html { redirect_to subsystem_tags_path, notice: "Subsystem tag '' was successfully created." }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def update
    if @subsystem_tag.update(subsystem_tag_params)
      redirect_to subsystem_tags_path, notice: 'Subsystem tag was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @subsystem_tag.destroy

    redirect_to subsystem_tags_url, notice: 'Subsystem tag was successfully deleted.'
  end

  def content_subtitle
    @subsystem_tag&.name.presence || super
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
