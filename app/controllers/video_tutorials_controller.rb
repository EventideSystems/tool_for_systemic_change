class VideoTutorialsController < ApplicationController
  before_action :set_video_tutorial, only: [:show, :edit, :update, :destroy]

  # GET /video_tutorials
  # GET /video_tutorials.json
  def index
    @video_tutorials = VideoTutorial.all
  end

  # GET /video_tutorials/1
  # GET /video_tutorials/1.json
  def show
  end

  # GET /video_tutorials/new
  def new
    @video_tutorial = VideoTutorial.new
  end

  # GET /video_tutorials/1/edit
  def edit
  end

  # POST /video_tutorials
  # POST /video_tutorials.json
  def create
    @video_tutorial = VideoTutorial.new(video_tutorial_params)

    respond_to do |format|
      if @video_tutorial.save
        format.html { redirect_to @video_tutorial, notice: 'Video tutorial was successfully created.' }
        format.json { render :show, status: :created, location: @video_tutorial }
      else
        format.html { render :new }
        format.json { render json: @video_tutorial.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /video_tutorials/1
  # PATCH/PUT /video_tutorials/1.json
  def update
    respond_to do |format|
      if @video_tutorial.update(video_tutorial_params)
        format.html { redirect_to @video_tutorial, notice: 'Video tutorial was successfully updated.' }
        format.json { render :show, status: :ok, location: @video_tutorial }
      else
        format.html { render :edit }
        format.json { render json: @video_tutorial.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /video_tutorials/1
  # DELETE /video_tutorials/1.json
  def destroy
    @video_tutorial.destroy
    respond_to do |format|
      format.html { redirect_to video_tutorials_url, notice: 'Video tutorial was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video_tutorial
      @video_tutorial = VideoTutorial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_tutorial_params
      params.fetch(:video_tutorial, {})
    end
end
