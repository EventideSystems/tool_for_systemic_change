# frozen_string_literal: true

class AddCodeToLegacySdgDataModels < ActiveRecord::Migration[8.0]
  def up
    execute %q(
      update focus_areas
      set code = source.code
      from (
        select 
          substring(focus_areas.name, 'Goal (\d+)\.') as code, 
          focus_areas.id
        from focus_areas 
        inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
        inner join data_models on focus_area_groups.data_model_id = data_models.id
        where data_models.name = 'Sustainable Development Goals'
        and focus_areas.code is null
      ) AS source
      where focus_areas.id = source.id
    )

    execute %q(
      update characteristics
      set code = source.code
      from (
        select 
          substring(characteristics.name, '^(\d+\.[\da-zA-Z]+)') as code, 
          characteristics.id
        from characteristics
        inner join focus_areas on characteristics.focus_area_id = focus_areas.id 
        inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
        inner join data_models on focus_area_groups.data_model_id = data_models.id
        where data_models.name = 'Sustainable Development Goals'
        and characteristics.code is null
      ) AS source
      where characteristics.id = source.id
    )
  end

  def down
    execute %q(
      update focus_areas
      set code = null
      from (
        select 
          focus_areas.id
        from focus_areas 
        inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
        inner join data_models on focus_area_groups.data_model_id = data_models.id
        where data_models.name = 'Sustainable Development Goals'
        and focus_areas.code is not null
      ) AS source
      where focus_areas.id = source.id
    )

    execute %q(
      update characteristics
      set code = null
      from (
        select 
          characteristics.id
        from characteristics
        inner join focus_areas on characteristics.focus_area_id = focus_areas.id 
        inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
        inner join data_models on focus_area_groups.data_model_id = data_models.id
        where data_models.name = 'Sustainable Development Goals'
        and characteristics.code is not null
      ) AS source
      where characteristics.id = source.id
    )
  end
end
