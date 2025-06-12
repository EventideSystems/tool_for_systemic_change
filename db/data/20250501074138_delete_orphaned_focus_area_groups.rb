# frozen_string_literal: true

class DeleteOrphanedFocusAreaGroups < ActiveRecord::Migration[8.0]
  def up
    FocusAreaGroup.where(data_model_id: nil).find_each do |focus_area_group|
      focus_area_group.focus_areas.each do |focus_area|
        focus_area.characteristics.delete_all
      end
      focus_area_group.focus_areas.delete_all
      focus_area_group.delete
    end
  end

  def down
    # NO OP
  end
end
