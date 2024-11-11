# frozen_string_literal: true

class SustainableDevelopmentGoalAlignmentCardPolicy < ScorecardPolicy # rubocop:disable Style/Documentation
  def characteristic?
    show?
  end
end
