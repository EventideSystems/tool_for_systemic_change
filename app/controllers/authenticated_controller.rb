class AuthenticatedController < ApplicationController
  include Concerns::DeserializeJsonApi

  before_filter :authenticate_user!

  class User::NotAuthorized < Exception; end

  rescue_from User::NotAuthorized do |exception|
    render json: exception, status: 403
  end

  def authenticate_staff_user!
    raise User::NotAuthorized unless current_user.staff?
  end

  def current_client
    if current_user.staff?
      Client.find(get_staff_client_id_from_session)
    else
      current_user.client
    end
  end

  private

  def get_staff_client_id_from_session
    current_client_id = session[:staff_current_client_id]
    session[:staff_current_client_id] = Client.first.id unless current_client_id

    session[:staff_current_client_id]
  end
end
