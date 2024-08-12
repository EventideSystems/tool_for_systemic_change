class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  layout 'home'

  sidebar_item :home

  def index
    redirect_to(dashboard_path) if user_signed_in?
  end

  def contributors; end
end
