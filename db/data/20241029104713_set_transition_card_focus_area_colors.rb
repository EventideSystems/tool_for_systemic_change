# frozen_string_literal: true

class SetTransitionCardFocusAreaColors < ActiveRecord::Migration[7.1]
  def up
    %w[FD6E77 FADD83 FEA785 AFBFF5 84ACD4 74C4DF 71B9B9 7AE0CC 7FD4A0].each_with_index do |color, index|
      focus_areas = FocusArea
        .joins(:focus_area_group)
        .where(
          focus_area_groups: { scorecard_type: 'TransitionCard' },
          focus_areas: { position: index + 1 },
          actual_color: nil
        )

      update_focus_area_color(focus_areas, color)
    end
  end

  def down
    # No need to revert this migration
  end

  def update_focus_area_color(focus_areas, color)
    focus_areas.update(actual_color: "##{color}")
  end
end
