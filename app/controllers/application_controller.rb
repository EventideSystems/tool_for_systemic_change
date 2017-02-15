class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
  
  protect_from_forgery with: :exception

  # SMELL Need to ensure that account is restricted to accounts available to current user
  def current_account
    account_id = session[:account_id]
    
    account_id.present? ? Account.find(account_id) : nil
  end
  
  def current_account=(account)
    session[:account_id] = account.id
  end
  
  def pundit_user
    UserContext.new(current_user, current_account)
  end

end
