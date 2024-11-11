# frozen_string_literal: true

class VideoTutorialsController < ApplicationController
  include VerifyPolicies

  before_action :set_video_tutorial, only: %i[show edit update destroy]

  def index
    @video_tutorials = policy_scope(VideoTutorial).order(sort_order).page params[:page]
  end

  def show
    render layout: false
  end

  def new
    @video_tutorial = VideoTutorial.new
    authorize @video_tutorial
  end

  def edit; end

  def create
    @video_tutorial = VideoTutorial.new(video_tutorial_params)
    authorize @video_tutorial

    respond_to do |format|
      if @video_tutorial.save
        format.html { redirect_to video_tutorials_path, notice: 'Video tutorial was successfully created.' }
        format.json { render :show, status: :created, location: @video_tutorial }
      else
        format.html { render :new }
        format.json { render json: @video_tutorial.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @video_tutorial.update(video_tutorial_params)
        format.html { redirect_to video_tutorials_path, notice: 'Video tutorial was successfully updated.' }
        format.json { render :show, status: :ok, location: @video_tutorial }
      else
        format.html { render :edit }
        format.json { render json: @video_tutorial.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @video_tutorial.destroy
    respond_to do |format|
      format.html { redirect_to video_tutorials_url, notice: 'Video tutorial was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def content_subtitle
    @video_tutorial&.name.presence || super
  end

  private

  def set_video_tutorial
    @video_tutorial = VideoTutorial.find(params[:id])
    authorize @video_tutorial
  end

  def video_tutorial_params
    params.fetch(:video_tutorial, {}).permit(
      :name,
      :description,
      :link_url,
      :position,
      :promote_to_dashboard
    )
  end
end
