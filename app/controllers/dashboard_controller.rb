class DashboardController < ApplicationController
  
  skip_after_action :verify_policy_scoped
  
  def index
    add_breadcrumb "Dashboard"
  end
end
