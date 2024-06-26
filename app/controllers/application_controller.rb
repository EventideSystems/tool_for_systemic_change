# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_session_account_id, unless: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_paper_trail_whodunnit
  before_action :enable_profiler
  before_action :prepare_exception_notifier

  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  # protect_from_forgery with: :exception
  protect_from_forgery prepend: true

  impersonates :user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :flash_resource_not_found

  add_breadcrumb "<i class='fa fa-dashboard'></i> Home".html_safe, :root_path

  helper_method :current_account, :sidebar_disabled?, :search_disabled?

  # SMELL Need to ensure that account is restricted to accounts available to current user
  def current_account
    @current_account ||=
      begin
        account_id = session[:account_id]
        account_id.present? ? ::Account.where(id: account_id).first : nil
      end
  end

  def sidebar_disabled?
    current_account.nil?
  end

  def current_account=(account)
    @current_account = nil
    session[:account_id] = account.present? ? account.id : nil
    current_account
  end

  def enable_profiler
    return unless ::Rails.env.development? || ::Rails.env.staging?

    ::Rack::MiniProfiler.authorize_request
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

  def content_title
    controller_name.titleize
  end

  def content_subtitle
    @content_subtitle || ''
  end

  def info_for_paper_trail
    { account_id: current_account&.id }
  end

  def user_for_paper_trail
    true_user&.id
  end

  protected

  def sort_order
    return { name: :asc } unless params[:order].present?

    sort_mode = params[:sort_mode].blank? ? :asc : params[:sort_mode].to_sym
    { params[:order].to_sym => sort_mode }
  end

  private

  def prepare_exception_notifier
    request.env['exception_notifier.exception_data'] = { current_user: }
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
