# frozen_string_literal: true

# Controller for the dashboard (logged-in home page)
class DashboardController < ApplicationController
  before_action :require_workspace, only: :index

  sidebar_item :home

  def index
    @scorecard_count = policy_scope(Scorecard).count
    @initiative_count = policy_scope(Initiative).count
    @wicked_problem_count = policy_scope(WickedProblem).count
    @organisation_count = policy_scope(Organisation).count

    @recent_versions = current_workspace.present? ? recent_activity : []
  end

  private

  def require_workspace
    flash[:alert] = 'Select an workspace before continuing.' if current_workspace.blank?
  end

  def recent_activity
    policy_scope(PaperTrail::Version).limit(7).order(created_at: :desc)
  end
end
