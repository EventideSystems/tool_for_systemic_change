class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  
  
  def current_account
    account_id = session[:account_id]
    
    account_id.present? ? Account.find(account_id) : nil
  end
  
  def current_account=(account)
    session[:account_id] = account.id
  end

end
