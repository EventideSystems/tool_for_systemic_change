# frozen_string_literal: true

class UpdatePositionsToStartAtOne < ActiveRecord::Migration[8.0]
  def up
    # Update all positions to start at 1
    Characteristic.where(position: 0).find_each do |characteristic|
      execute <<-SQL
        UPDATE characteristics
        SET position = position + 1
        WHERE characteristics.focus_area_id = #{characteristic.focus_area_id}
      SQL
    end

    FocusArea.where(position: 0).find_each do |focus_area|
      execute <<-SQL
        UPDATE focus_areas
        SET position = position + 1
        WHERE focus_areas.focus_area_group_id = #{focus_area.focus_area_group_id}
      SQL
    end

    FocusAreaGroup.where(position: 0).where.not(data_model_id: nil).find_each do |focus_area_group|
      execute <<-SQL
        UPDATE focus_area_groups
        SET position = position + 1
        WHERE focus_area_groups.data_model_id = #{focus_area_group.data_model_id}
      SQL
    end
  end

  def down
    # No need to revert this migration
  end
end
