class CommunitiesController < ApplicationController
  before_action :set_community, only: [:show, :edit, :update, :destroy]
  before_action :require_account_selected, only: [:new, :create, :edit, :update] 

  def index
    @communities = policy_scope(Community)
  end

  def show
  end

  def new
    @community = current_account.communities.build
    authorize @community 
  end

  def edit
  end

  def create
    @community = current_account.communities.build(community_params)
    authorize @community

    respond_to do |format|
      if @community.save
        format.html { redirect_to @community, notice: 'Community was successfully created.' }
        format.json { render :show, status: :created, location: @community }
      else
        format.html { render :new }
        format.json { render json: @community.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @community.update(community_params)
        format.html { redirect_to @community, notice: 'Community was successfully updated.' }
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
      format.html { redirect_to communities_url, notice: 'Community was successfully destroyed.' }
      format.json { head :no_content }
    end
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
