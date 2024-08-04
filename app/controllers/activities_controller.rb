# frozen_string_literal: true

class ActivitiesController < ApplicationController
  before_action :authenticate_user!

  # add_breadcrumb 'Activities', :activities_path

  def index
    @versions = policy_scope(PaperTrail::Version).order(sort_order).page(params[:page])
  end

  def sort_order
    return { created_at: :desc } unless params[:order].present?

    super
  end
end
