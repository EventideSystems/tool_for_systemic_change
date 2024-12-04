# frozen_string_literal: true

# Helper methods for presenting focus area groups
module FocusAreaGroupsHelper
  def options_for_scorecard_type
    [SustainableDevelopmentGoalAlignmentCard, TransitionCard].map do |klass|
      [klass.name.demodulize.titleize, klass.name]
    end
  end
end
