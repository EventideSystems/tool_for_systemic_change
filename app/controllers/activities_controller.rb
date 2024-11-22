# frozen_string_literal: true

# Controller for Activities
class ActivitiesController < ApplicationController
  include VerifyPolicies

  sidebar_item :home

  def index
    versions = policy_scope(PaperTrail::Version).order(created_at: :desc)

    @pagy, @versions = pagy(versions, limit: 10)

    respond_to do |format|
      format.html { render 'activities/index', locals: { versions: @versions } }
      format.turbo_stream { render 'activities/index', locals: { versions: @versions } }
    end
  end
end
