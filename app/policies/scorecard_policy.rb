# frozen_string_literal: true

class ScorecardPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      resolve_to_current_account.where(type: current_account_scorecard_types)
    end

    private

    def current_account_scorecard_types
      current_account&.scorecard_types&.map(&:name).presence || []
    end
  end

  def index?
    system_admin? || account_any_role?(current_account)
  end

  def show?
    system_admin? || account_any_role?(record.account)
  end

  def create?
    system_admin? || (current_account_admin? && max_scorecards_not_reached?(user_context.account))
  end

  def update?
    system_admin? || current_account_admin?
  end

  def destroy?
    system_admin? || current_account_admin?
  end

  def show_shared_link?
    system_admin? || account_any_role?(record.account)
  end

  def copy?
    create?
  end

  def copy_options?
    copy?
  end

  def merge?
    system_admin? || current_account_admin?
  end

  def merge_options?
    merge?
  end

  def activity?
    system_admin? || account_any_role?(record.account)
  end

  def changes?
    system_admin? || account_any_role?(record.account)
  end

  def activities?
    system_admin? || account_any_role?(record.account)
  end

  def max_scorecards_not_reached?(account)
    return false if account.blank?
    return true if account.max_scorecards.zero? # NOTE: magic number, meaning no limit

    account.scorecards.count < account.max_scorecards
  end

  def ecosystem_maps?
    system_admin? || current_account&.solution_ecosystem_maps?
  end

  # TODO: Will need to check this against account option, per spec
  def ecosystem_maps_organisations?
    ecosystem_maps?
  end

  # TODO: Rename this to 'show_targets_network_map?'
  def targets_network_maps?
    record.is_a?(SustainableDevelopmentGoalAlignmentCard) &&
      record.account.allow_sustainable_development_goal_alignment_cards?
  end

  def targets_network_map?
    targets_network_maps?
  end

  def link_scorecards?
    record.account.allow_transition_cards? && record.account.allow_sustainable_development_goal_alignment_cards?
  end

  def share_ecosystem_maps?
    system_admin? || (current_account&.solution_ecosystem_maps? && current_account_admin?)
  end

  def share_thematic_network_maps?
    system_admin? || (current_account&.allow_sustainable_development_goal_alignment_cards? && current_account_admin?)
  end

  def linked_initiatives?
    show?
  end
end
