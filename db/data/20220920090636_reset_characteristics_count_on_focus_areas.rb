# frozen_string_literal: true

class ResetCharacteristicsCountOnFocusAreas < ActiveRecord::Migration[7.0]
  def up
    FocusArea.find_each do |focus_area|
      FocusArea.reset_counters(focus_area.id, :characteristics)
    end
  end

  def down
    # NO OP
  end
end
