# frozen_string_literal: true

class UpdateChecklistItemCharacteristicId < ActiveRecord::Migration[7.0]
  def up
    execute(<<~SQL)
      update checklist_items
      set previous_characteristic_id = characteristic_id
    SQL

    Account.with_deleted.find_each do |account|
      next if account.initiatives.empty?

      execute(<<~SQL)
        update checklist_items
        set characteristic_id = targets.target_characteristic_id
        from (
          select distinct
            current_characteristics.id as current_characteristic_id,
            target_characteristics.id as target_characteristic_id,
            initiatives.id as initiative_id
          from checklist_items
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          inner join scorecards on scorecards.id = initiatives.scorecard_id
          inner join focus_area_groups on focus_area_groups.account_id = scorecards.account_id
          inner join focus_areas on focus_areas.focus_area_group_id = focus_area_groups.id
          inner join characteristics target_characteristics on target_characteristics.focus_area_id = focus_areas.id
          inner join characteristics current_characteristics on current_characteristics.id = checklist_items.characteristic_id
          where current_characteristics.name = target_characteristics.name
          and scorecards.account_id = #{account.id}
        ) as targets
        where checklist_items.characteristic_id = targets.current_characteristic_id
        and checklist_items.initiative_id = targets.initiative_id
      SQL
    end
  end

  def down
    execute(<<~SQL)
      update checklist_items
      set characteristic_id = previous_characteristic_id
    SQL

    execute(<<~SQL)
      update checklist_items
      set previous_characteristic_id = null
    SQL
  end
end


# select distinct current_characteristics.id, target_characteristics.id from checklist_items
# inner join initiatives on initiatives.id = checklist_items.initiative_id
# inner join scorecards on scorecards.id = initiatives.scorecard_id
# inner join focus_area_groups on focus_area_groups.account_id = scorecards.account_id
# inner join focus_areas on focus_areas.focus_area_group_id = focus_area_groups.id
# inner join characteristics target_characteristics on characteristics.focus_area_id = focus_areas.id
# inner join characteristics current_characteristics on current_characteristics.id = checklist_items.characteristic_id
# where current_characteristics.name = target_characteristics.name
# and scorecards.account_id = 15;
