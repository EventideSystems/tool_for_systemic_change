# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ActiveSidebarItem
  include Pagy::Backend

  before_action :set_session_account_id
  before_action :authenticate_user!

  before_action :set_paper_trail_whodunnit

  # protect_from_forgery with: :exception
  protect_from_forgery prepend: true

  impersonates :user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :flash_resource_not_found

  sidebar_item :home

  def current_account
    return nil if current_user.blank?

    @current_account ||= fetch_account_from_session || fetch_default_account_and_set_session
  end

  helper_method :current_account

  def current_account=(account)
    @current_account = nil
    session[:account_id] = account.present? ? account.id : nil
    current_account
  end

  def pundit_user
    UserContext.new(current_user, current_account)
  end

  def require_account_selected
    return if current_account.present?

    redirect_back(fallback_location: dashboard_path, alert: 'Select an account before using this feature')
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :invite,
      keys: [
        :email,
        :name,
        :system_role,
        { accounts_users_attributes: %i[account_id account_role] }
      ]
    )
  end

  def info_for_paper_trail
    { account_id: current_account&.id }
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

  def fetch_account_from_session
    return nil if session[:account_id].blank?

    AccountPolicy::Scope
      .new(UserContext.new(current_user, nil), Account)
      .scope
      .find_by(id: session[:account_id])
  end

  def fetch_default_account_and_set_session
    default_account = current_user&.default_account
    session[:account_id] = default_account&.id
    default_account
  end

  def set_session_account_id
    return unless session[:account_id].blank? && user_signed_in?

    self.current_account = current_user.default_account
  end

  def user_not_authorized(_exception)
    flash[:error] = 'Access denied.'
    # TODO: Would be nicer to have specific error messages, but for now just use "Access denied."
    # flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(root_path)
  end

  def flash_resource_not_found(_exception)
    flash[:error] = "Resource not found in account '#{current_account.name}'"
    redirect_to(root_path)
  end
end
