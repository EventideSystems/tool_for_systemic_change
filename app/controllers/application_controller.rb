class ApplicationController < ActionController::Base
  include Pundit
  include PublicActivity::StoreController
  
  force_ssl if: :ssl_configured?

  def ssl_configured?
    Rails.env.production?
  end

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_session_account_id, unless: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller? 
  before_action :set_paper_trail_whodunnit

  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  # protect_from_forgery with: :exception
  protect_from_forgery prepend: true
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  add_breadcrumb "<i class='fa fa-dashboard'></i> Home".html_safe, :root_path

  # SMELL Need to ensure that account is restricted to accounts available to current user
  def current_account
    account_id = session[:account_id]
    
    account_id.present? ? Account.where(id: account_id).first : nil
  end
  
  def current_account=(account)
    session[:account_id] = account.present? ? account.id : nil
  end
  
  def pundit_user
    UserContext.new(current_user, current_account)
  end
  
  def require_account_selected
    return if current_account.present?
    
    redirect_back(
      fallback_location: dashboard_path, 
      alert: 'Select an account before using this feature'
    )
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, 
      keys:[
        :email, 
        :name, 
        :system_role, 
        accounts_users_attributes: [:account_id, :account_role]
      ]
    )
  end
  
  def content_title
    controller_name.titleize
  end
  
  def content_subtitle
    @content_subtitle || ''
  end
  
  protected
  
  def sort_order
    return { name: :asc } unless params[:order].present?
    
    sort_mode = params[:sort_mode].blank? ? :asc : params[:sort_mode].to_sym
    { params[:order].to_sym => sort_mode } 
  end

  private

  def set_session_account_id
   if session[:account_id].blank? && user_signed_in?
     self.current_account = current_user.default_account
   end
  end

  def user_not_authorized(exception)
   policy_name = exception.policy.class.to_s.underscore
   flash[:error] = "Access denied."
   # TODO Would be nicer to have specific error messages, but for now just use "Access denied."
  # flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
   redirect_to(request.referrer || root_path)
  end

end
