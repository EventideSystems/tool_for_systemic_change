class RemoveFocusAreasCharacteristicsCount < ActiveRecord::Migration[7.0]
  def change
    remove_column :focus_areas, :characteristics_count, :integer
  end
end
