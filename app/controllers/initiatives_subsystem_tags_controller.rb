class InitiativesOrganisationsController < ApplicationController
  before_action :set_initiatives_subsystem_tag, only: [:show, :edit, :update, :destroy]

  # GET /initiatives_subsystem_tags
  # GET /initiatives_subsystem_tags.json
  def index
    @initiatives_subsystem_tags = InitiativesOrganisation.all
  end

  # GET /initiatives_subsystem_tags/1
  # GET /initiatives_subsystem_tags/1.json
  def show
  end

  # GET /initiatives_subsystem_tags/new
  def new
    @initiatives_subsystem_tag = InitiativesOrganisation.new
  end

  # GET /initiatives_subsystem_tags/1/edit
  def edit
  end

  # POST /initiatives_subsystem_tags
  # POST /initiatives_subsystem_tags.json
  def create
    @initiatives_subsystem_tag = InitiativesOrganisation.new(initiatives_subsystem_tag_params)

    respond_to do |format|
      if @initiatives_subsystem_tag.save
        format.html { redirect_to @initiatives_subsystem_tag, notice: 'Initiatives Subsystem Tag was successfully created.' }
        format.json { render :show, status: :created, location: @initiatives_subsystem_tag }
      else
        format.html { render :new }
        format.json { render json: @initiatives_subsystem_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /initiatives_subsystem_tags/1
  # PATCH/PUT /initiatives_subsystem_tags/1.json
  def update
    respond_to do |format|
      if @initiatives_subsystem_tag.update(initiatives_subsystem_tag_params)
        format.html { redirect_to @initiatives_subsystem_tag, notice: 'Initiatives Subsystem Tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @initiatives_subsystem_tag }
      else
        format.html { render :edit }
        format.json { render json: @initiatives_subsystem_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /initiatives_subsystem_tags/1
  # DELETE /initiatives_subsystem_tags/1.json
  def destroy
    @initiatives_subsystem_tag.destroy
    respond_to do |format|
      format.html { redirect_to initiatives_subsystem_tags_url, notice: 'Initiatives Subsystem Tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_initiatives_subsystem_tag
      @initiatives_subsystem_tag = InitiativesOrganisation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def initiatives_subsystem_tag_params
      params.fetch(:initiatives_subsystem_tag, {})
    end
end
