class AuthenticatedController < ApplicationController
  include Concerns::DeserializeJsonApi
  include PublicActivity::StoreController

  before_filter :authenticate_user!

  class User::NotAuthorized < Exception; end

  class InvalidPaginationRequest < Exception; end

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

  def current_client_id
    current_client ? current_client.id : nil
  end

  protected

  def finder_for_pagination(query)
    check_pagination_params

    if params[:limit]
      query = query.limit(params[:limit])
    end

    if params[:page]
      query = query.page(params[:page])
    end

    if params[:per]
      query = query.per(params[:per])
    end

    query
  end

  private

  def check_pagination_params
    if params[:limit] && (params[:page] || params[:per])
      raise InvalidPaginationRequest, "Cannot mix :limit and :per/:page params"
    end

    if params[:page] && !params[:per]
      raise InvalidPaginationRequest, "Missing :per pagination param"
    end

    if params[:per] && !params[:page]
      raise InvalidPaginationRequest, "Missing :page pagination param"
    end
  end

  def get_staff_client_id_from_session
    client_id = session[:staff_current_client_id]
    client_id = nil unless Client.exists?(client_id)

    session[:staff_current_client_id] = Client.first.id unless client_id

    session[:staff_current_client_id]
  end
end
