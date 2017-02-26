class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?
  
  before_action :set_session_account_id, unless: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller? 
  
  protect_from_forgery with: :exception
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # SMELL Need to ensure that account is restricted to accounts available to current user
  def current_account
    account_id = session[:account_id]
    
    account_id.present? ? Account.find(account_id) : nil
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
