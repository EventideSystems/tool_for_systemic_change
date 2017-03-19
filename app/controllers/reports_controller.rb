class ReportsController < ApplicationController
  
  skip_after_action :verify_policy_scoped
  
  def index
    authorize :report, :index?
  end
end
