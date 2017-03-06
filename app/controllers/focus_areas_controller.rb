class FocusAreasController < ApplicationController
  before_action :set_focus_area, only: [:show, :edit, :update, :destroy]

  # GET /focus_areas
  # GET /focus_areas.json
  def index
    @focus_areas = FocusArea.all
  end

  # GET /focus_areas/1
  # GET /focus_areas/1.json
  def show
  end

  # GET /focus_areas/new
  def new
    @focus_area = FocusArea.new
  end

  # GET /focus_areas/1/edit
  def edit
  end

  # POST /focus_areas
  # POST /focus_areas.json
  def create
    @focus_area = FocusArea.new(focus_area_params)

    respond_to do |format|
      if @focus_area.save
        format.html { redirect_to @focus_area, notice: 'Focus area was successfully created.' }
        format.json { render :show, status: :created, location: @focus_area }
      else
        format.html { render :new }
        format.json { render json: @focus_area.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /focus_areas/1
  # PATCH/PUT /focus_areas/1.json
  def update
    respond_to do |format|
      if @focus_area.update(focus_area_params)
        format.html { redirect_to @focus_area, notice: 'Focus area was successfully updated.' }
        format.json { render :show, status: :ok, location: @focus_area }
      else
        format.html { render :edit }
        format.json { render json: @focus_area.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /focus_areas/1
  # DELETE /focus_areas/1.json
  def destroy
    @focus_area.destroy
    respond_to do |format|
      format.html { redirect_to focus_areas_url, notice: 'Focus area was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_focus_area
      @focus_area = FocusArea.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def focus_area_params
      params.fetch(:focus_area, {})
    end
end
