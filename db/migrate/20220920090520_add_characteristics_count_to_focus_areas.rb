class AddCharacteristicsCountToFocusAreas < ActiveRecord::Migration[7.0]
  def change
    add_column :focus_areas, :characteristics_count, :integer, default: 0
  end
end
