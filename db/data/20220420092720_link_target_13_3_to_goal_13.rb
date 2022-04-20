# frozen_string_literal: true

class LinkTarget133ToGoal13 < ActiveRecord::Migration[6.1]
  def up
    goal_13 = find_goal_13
    characteristic_13_3 = find_characteristic_13_3

    TargetsNetworkMapping.find_or_create_by(
      characteristic_id: characteristic_13_3.id,
      focus_area_id: goal_13.id
    )

  end

  def down
    goal_13 = find_goal_13
    characteristic_13_3 = find_characteristic_13_3

    TargetsNetworkMapping.find_by(
      characteristic_id: characteristic_13_3.id,
      focus_area_id: goal_13.id
    )&.destroy
  end

  private

  def find_goal_13
    FocusArea
      .per_scorecard_type('SustainableDevelopmentGoalAlignmentCard')
      .where(["focus_areas.name like ?", "%Goal 13.%"]).first
  end

  def find_characteristic_13_3
    Characteristic
      .per_scorecard_type('SustainableDevelopmentGoalAlignmentCard')
      .where(["characteristics.name like ?", "13.3 %"]).first
  end
end
