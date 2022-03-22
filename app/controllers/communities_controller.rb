class CommunitiesController < ApplicationController
  before_action :set_community, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update]

  add_breadcrumb "Communities", :communities_path

  def index
    @communities = policy_scope(Community).order(sort_order).page(params[:page])
  end

  def show
    @community.readonly!
    add_breadcrumb @community.name
  end

  def new
    @community = current_account.communities.build
    authorize @community
    add_breadcrumb "New"
  end

  def edit
    add_breadcrumb @community.name
  end

  def create
    @community = current_account.communities.build(community_params)
    authorize @community

    respond_to do |format|
      if @community.save
        format.html { redirect_to communities_path, notice: 'Community was successfully created.' }
        format.json { render :show, status: :created, location: @community }
        format.js
      else
        format.html { render :new }
        format.json { render json: @community.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @community.update(community_params)
        format.html { redirect_to communities_path, notice: 'Community was successfully updated.' }
        format.json { render :show, status: :ok, location: @community }
      else
        format.html { render :edit }
        format.json { render json: @community.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @community.destroy
    respond_to do |format|
      format.html { redirect_to communities_url, notice: 'Community was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def content_subtitle
    return @community.name if @community.present?
    super
  end

  private

    def set_community
      @community = current_account.communities.find(params[:id])
      authorize @community
    end

    def community_params
      params.fetch(:community, {}).permit(:name, :description)
    end
end
