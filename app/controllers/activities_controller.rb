# frozen_string_literal: true

class ActivitiesController < ApplicationController
  include VerifyPolicies

  before_action :authenticate_user!

  def index
    @versions = policy_scope(PaperTrail::Version).order(sort_order).page(params[:page])
  end

  def sort_order
    return { created_at: :desc } if params[:order].blank?

    super
  end
end
