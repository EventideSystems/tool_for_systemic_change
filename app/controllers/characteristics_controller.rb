class CharacteristicsController < ApplicationController
  before_action :set_characteristic, only: [:show, :edit, :update, :destroy]

  def index
    @characteristics = policy_scope(Characteristic).order(sort_order).page params[:page]
  end

  def show
  end

  def new
    @characteristic = Characteristic.new 
    authorize @characteristic
  end

  def edit
  end

  def create
    @characteristic = Characteristic.new(characteristic_params)
    authorize @characteristic
    
    respond_to do |format|
      if @characteristic.save
        format.html { redirect_to characteristics_path, notice: 'Characteristic was successfully created.' }
        format.json { render :show, status: :created, location: @characteristic }
      else
        format.html { render :new }
        format.json { render json: @characteristic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @characteristic.update(characteristic_params)
        format.html { redirect_to characteristics_path, notice: 'Characteristic was successfully updated.' }
        format.json { render :show, status: :ok, location: @characteristic }
      else
        format.html { render :edit }
        format.json { render json: @characteristic.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @characteristic.destroy
    respond_to do |format|
      format.html { redirect_to characteristics_url, notice: 'Characteristic was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def content_subtitle
    return @characteristic.name if @characteristic.present?
    super
  end

  private
    def set_characteristic
      @characteristic = Characteristic.find(params[:id])
      authorize @characteristic
    end

    def characteristic_params
      params.fetch(:characteristic, {}).permit(:name, :description, :focus_area_id, :position, :video_tutorial_id)
    end
end
