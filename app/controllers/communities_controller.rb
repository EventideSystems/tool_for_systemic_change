class CommunitiesController < ApplicationController
  before_action :set_community, only: %i[show edit update destroy]
  before_action :require_account_selected, only: %i[new create edit update]

  # add_breadcrumb 'Communities', :communities_path

  def index
    @communities = policy_scope(Community).order(sort_order).page(params[:page])
  end

  def show
    @community.readonly!
    # add_breadcrumb(@community.name)

    respond_to do |format|
      format.html { render(:show) }
      format.json { render(json: @community) }
    end
  end

  def new
    @community = current_account.communities.build
    authorize(@community)
    # add_breadcrumb('New')
  end

  def edit
    # add_breadcrumb(@community.name)
  end

  def create
    @community = current_account.communities.build(community_params)
    authorize(@community)

    respond_to do |format|
      if @community.save
        format.html { redirect_to(communities_path, notice: 'Community was successfully created.') }
        format.js
      else
        format.html { render(:new) }
        format.js { render(json: @community.errors, status: :unprocessable_entity) }
      end
    end
  end

  def update
    if @community.update(community_params)
      respond_to do |format|
        format.html { redirect_to(communities_path, notice: 'Community was successfully updated.') }
        format.js
      end
    else
      respond_to do |format|
        format.html { render(:edit) }
        format.js { render(json: @community.errors, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @community.destroy

    redirect_to(communities_url, notice: 'Community was successfully deleted.')
  end

  def content_subtitle
    @community&.name.presence || super
  end

  private

  def set_community
    @community = current_account.communities.find(params[:id])
    authorize(@community)
  end

  def community_params
    params.fetch(:community, {}).permit(:name, :description)
  end
end
