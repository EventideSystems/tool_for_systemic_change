class AuthenticatedController < ApplicationController
  include Concerns::DeserializeJsonApi

  before_filter :authenticate_user!

  class User::NotAuthorized < Exception; end;

  rescue_from User::NotAuthorized do |exception|
    render json: exception, status: 403
  end
end
