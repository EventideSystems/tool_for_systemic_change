class AddIndicesForOptimisation < ActiveRecord::Migration
  def change
    add_index(:characteristics, :position)
    add_index(:characteristics, :focus_area_id)

    add_index(:focus_areas, :position)
    add_index(:focus_areas, :focus_area_group_id)

    add_index(:focus_area_groups, :position)

    add_index(:checklist_items, :characteristic_id)
    add_index(:checklist_items, :initiative_id)

    add_index(:initiatives, :scorecard_id)

    add_index(:communities, :client_id)
    add_index(:organisations, :client_id)
    add_index(:scorecards, :client_id)
    add_index(:users, :client_id)

    add_index(:initiatives_organisations, [:initiative_id, :organisation_id], unique: true, name: 'initiatives_organisations_index')
  end
end
