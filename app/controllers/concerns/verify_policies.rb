# frozen_string_literal: true

# Ensure Pundit policies and scopes are used and verified
# NB - this is a controller concern, so it should be included in the ApplicationController, but with
# changes Rails defaults it will trigger errors when controllers have no index (e.g. Devise controllers)
module VerifyPolicies
  extend ActiveSupport::Concern

  def index; end

  included do
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
  end
end
