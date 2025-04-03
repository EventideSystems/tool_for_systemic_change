# frozen_string_literal: true

# Controller for Workspaces
class WorkspacesController < ApplicationController
  include VerifyPolicies

  before_action :set_workspace, only: %i[show edit update destroy switch]

  def index
    search_params = params.permit(:format, :page, q: [:name_or_description_cont])

    @q = policy_scope(Workspace).order(:name).ransack(search_params[:q])

    workspaces = @q.result(distinct: true)

    @pagy, @workspaces = pagy(workspaces, limit: 10)

    respond_to do |format|
      format.html { render 'workspaces/index', locals: { workspaces: @workspaces } }
      format.turbo_stream { render 'workspaces/index', locals: { workspaces: @workspaces } }
    end
  end

  def show
    @workspace.readonly!
    render 'show'
  end

  def new
    @workspace = Workspace.new(expires_on: Time.zone.today + 1.year)
    authorize(@workspace)
  end

  def edit; end

  def create
    @workspace = Workspace.new(workspace_params)
    authorize(@workspace)

    if @workspace.save
      redirect_to(edit_workspace_path(@workspace), notice: 'Workspace was successfully created.')
    else
      render(:new)
    end
  end

  def update
    if @workspace.update(workspace_params)
      redirect_to(workspace_path(@workspace), notice: 'Workspace was successfully updated.')
    else
      render(:edit)
    end
  end

  def destroy
    @workspace.destroy
    redirect_to(workspaces_url, notice: 'Workspace was successfully deleted.')
  end

  def switch
    self.current_workspace = @workspace
    redirect_to(dashboard_path, notice: 'Workspace successfully switched.')
  end

  def content_subtitle
    @workspace&.name.presence || super
  end

  private

  def set_workspace
    @workspace = Workspace.find(params[:id])
    authorize(@workspace)
  end

  def workspace_params
    params.fetch(:workspace, {}).permit(
      :name,
      :description,
      :classic_grid_mode,
      :deactivated,
      :expires_on,
      :max_users,
      :max_scorecards
    )
  end
end
