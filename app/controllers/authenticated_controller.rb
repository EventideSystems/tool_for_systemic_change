class AuthenticatedController < ApplicationController
  include Concerns::DeserializeJsonApi

  before_filter :authenticate_user!

  class User::NotAuthorized < Exception; end;

  rescue_from User::NotAuthorized do |exception|
    render json: exception, status: 403
  end

  def authenticate_staff_user!
    raise User::NotAuthorized unless current_user.staff?
  end
end
