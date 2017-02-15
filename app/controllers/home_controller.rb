class HomeController < ApplicationController
  after_action :skip_authorization
  
  layout 'home'
  
  def index
    redirect_to(dashboard_path) if user_signed_in? 
  end
end
