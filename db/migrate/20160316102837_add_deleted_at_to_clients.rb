class AddDeletedAtToClients < ActiveRecord::Migration
  def change
    %i(
      characteristics
      checklist_items
      clients
      communities
      focus_area_groups
      focus_areas
      initiatives
      initiatives_organisations
      organisations
      scorecards
      sectors
      users
      video_tutorials
      wicked_problems
    ).each do |table|
      add_column table, :deleted_at, :datetime
      add_index table, :deleted_at
    end
  end
end
