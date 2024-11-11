# frozen_string_literal: true

# Controller for the dashboard (logged-in home page)
class DashboardController < ApplicationController
  before_action :require_account, only: :index

  sidebar_item :home

  def index
    @scorecard_count = policy_scope(Scorecard).count
    @initiative_count = policy_scope(Initiative).count
    @wicked_problem_count = policy_scope(WickedProblem).count
    @organisation_count = policy_scope(Organisation).count

    @recent_versions = current_account.present? ? recent_activity : []
  end

  private

  def require_account
    flash[:alert] = 'Select an account before continuing.' if current_account.blank?
  end

  def recent_activity
    policy_scope(PaperTrail::Version).limit(7).order(created_at: :desc)
  end
end
