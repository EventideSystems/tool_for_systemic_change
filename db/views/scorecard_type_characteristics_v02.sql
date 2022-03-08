  select characteristics.*, focus_area_groups.scorecard_type from characteristics
  inner join focus_areas on characteristics.focus_area_id = focus_areas.id
  inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
  order by focus_areas.position, characteristics.position
