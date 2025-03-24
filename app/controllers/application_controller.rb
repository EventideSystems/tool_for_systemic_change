# frozen_string_literal: true

# Base controller for the application
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ActiveSidebarItem
  include Pagy::Backend

  before_action :set_session_workspace_id
  before_action :authenticate_user!

  before_action :set_paper_trail_whodunnit

  # protect_from_forgery with: :exception
  protect_from_forgery prepend: true

  impersonates :user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :flash_resource_not_found

  sidebar_item :home

  def current_workspace
    return nil if current_user.blank?

    @current_workspace ||= fetch_workspace_from_session || fetch_default_workspace_and_set_session
  end

  helper_method :current_workspace

  def current_workspace=(workspace)
    @current_workspace = nil
    session[:workspace_id] = workspace.present? ? workspace.id : nil
    current_workspace
  end

  def pundit_user
    UserContext.new(current_user, current_workspace)
  end

  def require_workspace_selected
    return if current_workspace.present?

    redirect_back(fallback_location: dashboard_path, alert: 'Select an workspace before using this feature')
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :invite,
      keys: [
        :email,
        :name,
        :system_role,
        { workspaces_users_attributes: %i[workspace_id workspace_role] }
      ]
    )
  end

  def info_for_paper_trail
    { workspace_id: current_workspace&.id }
  end

  def user_for_paper_trail
    true_user&.id
  end

  protected

  def sort_order
    return { name: :asc } if params[:order].blank?

    sort_mode = params[:sort_mode].blank? ? :asc : params[:sort_mode].to_sym
    { params[:order].to_sym => sort_mode }
  end

  private

  def fetch_workspace_from_session
    return nil if session[:workspace_id].blank?

    WorkspacePolicy::Scope
      .new(UserContext.new(current_user, nil), Workspace)
      .scope
      .find_by(id: session[:workspace_id])
  end

  def fetch_default_workspace_and_set_session
    default_workspace = current_user&.default_workspace
    default_workspace = Workspace.active.first if default_workspace.blank? && current_user.system_role == 'admin'
    session[:workspace_id] = default_workspace&.id
    default_workspace
  end

  def set_session_workspace_id
    return unless session[:workspace_id].blank? && user_signed_in?

    self.current_workspace = current_user.default_workspace
  end

  def user_not_authorized(_exception)
    flash[:error] = 'Access denied.'
    # TODO: Would be nicer to have specific error messages, but for now just use "Access denied."
    # flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(root_path)
  end

  def flash_resource_not_found(_exception)
    flash[:error] = "Resource not found in workspace '#{current_workspace.name}'"
    redirect_to(root_path)
  end
end
