# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_permitted_parameters

  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  # skip_after_action :set_session_account_id
  # skip_after_action :authenticate_user!
end
