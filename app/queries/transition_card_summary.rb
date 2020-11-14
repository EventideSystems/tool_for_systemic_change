class TransitionCardSummary

  class << self
  private



end


# SELECT * 
# FROM crosstab($$
# select
# initiatives.name as initiative,
# characteristics.id as characteristic,
# (case checklist_items.checked
# when true then true
# else false
# end)::BOOL as checked
# from checklist_items
# inner join characteristics on characteristics.id = checklist_items.characteristic_id
# inner join focus_areas on focus_areas.id = characteristics.focus_area_id
# inner join initiatives on initiatives.id = checklist_items.initiative_id
# inner join scorecards on scorecards.id = initiatives.scorecard_id
# where scorecards.id = 5
# ORDER BY initiatives.name, focus_areas.position, characteristics.position
# $$,
# $$
# select characteristics.id from characteristics 
# inner join focus_areas on focus_areas.id = characteristics.focus_area_id
# order by focus_areas.position, characteristics.position
# $$
# )
# AS final_result(
#   initiative TEXT,
# "1" BOOL,
# "2" BOOL,
# "3" BOOL,
# "4" BOOL,
# "5" BOOL,
# "6" BOOL,
# "7" BOOL,
# "8" BOOL,
# "9" BOOL,
# "10" BOOL,
# "11" BOOL,
# "12" BOOL,
# "13" BOOL,
# "14" BOOL,
# "15" BOOL,
# "16" BOOL,
# "17" BOOL,
# "18" BOOL,
# "19" BOOL,
# "20" BOOL,
# "21" BOOL,
# "22" BOOL,
# "23" BOOL,
# "24" BOOL,
# "25" BOOL,
# "26" BOOL,
# "27" BOOL,
# "28" BOOL,
# "29" BOOL,
# "30" BOOL,
# "31" BOOL,
# "32" BOOL,
# "33" BOOL,
# "34" BOOL,
# "35" BOOL,
# "36" BOOL
# );



EXPLAIN  ANALYSE
SELECT * 
FROM crosstab($$
select
initiatives.name as initiative,
characteristics.id as characteristic,
jsonb_build_object(
  'name', characteristics.name,
  'checked', (
    case checklist_items.checked
    when true then true
    else false
    end
  )
)  

from checklist_items
inner join characteristics on characteristics.id = checklist_items.characteristic_id
inner join focus_areas on focus_areas.id = characteristics.focus_area_id
inner join initiatives on initiatives.id = checklist_items.initiative_id
inner join scorecards on scorecards.id = initiatives.scorecard_id
where scorecards.id = 5
ORDER BY initiatives.name, focus_areas.position, characteristics.position
$$,
$$
select characteristics.id from characteristics 
inner join focus_areas on focus_areas.id = characteristics.focus_area_id
order by focus_areas.position, characteristics.position
$$
)
AS final_result(
  initiative TEXT,
"1" JSONB,
"2" JSONB,
"3" JSONB,
"4" JSONB,
"5" JSONB,
"6" JSONB,
"7" JSONB,
"8" JSONB,
"9" JSONB,
"10" JSONB,
"11" JSONB,
"12" JSONB,
"13" JSONB,
"14" JSONB,
"15" JSONB,
"16" JSONB,
"17" JSONB,
"18" JSONB,
"19" JSONB,
"20" JSONB,
"21" JSONB,
"22" JSONB,
"23" JSONB,
"24" JSONB,
"25" JSONB,
"26" JSONB,
"27" JSONB,
"28" JSONB,
"29" JSONB,
"30" JSONB,
"31" JSONB,
"32" JSONB,
"33" JSONB,
"34" JSONB,
"35" JSONB,
"36" JSONB
);

