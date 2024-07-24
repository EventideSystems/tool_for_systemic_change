  select characteristics.*, focus_area_groups.scorecard_type, focus_area_groups.account_id from characteristics
  inner join focus_areas on characteristics.focus_area_id = focus_areas.id
  inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
  where characteristics.deleted_at is null
  and focus_areas.deleted_at is null
  and focus_area_groups.deleted_at is null
  order by focus_areas.position, characteristics.position
