# frozen_string_literal: true

class SetBaseColorsForFocusAreas < ActiveRecord::Migration[6.1]
  def up
    focus_areas.each_with_index do |focus_area, index|
      focus_area.update_column(:base_color, base_color(index))
    end
  end

  def down
    # NO OP
  end

  private

  def focus_areas
    FocusArea
      .where(focus_area_group: FocusAreaGroup.find_by(name: "SDG Targets"))
      .order(:position)
      .to_a
  end

  def base_color(index)
    FocusAreasHelper::SDG_COLORS[index]
  end
end
