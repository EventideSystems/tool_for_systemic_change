
# frozen_string_literal: true
require 'benchmark'

class NewScorecardGrid
  class << self

    def execute(scorecard)
      columns_data = ActiveRecord::Base.connection.execute(columns_data_sql(scorecard)).values.first.first

      ActiveRecord::Base
        .connection
        .execute(crosstab_sql(scorecard, columns_data))
        .map { |result|
          result.transform_values { |v| FastJsonparser.parse(v)  }
        }
    end

    private

    def columns_data_sql(scorecard)
      <<~SQL
        select
          array_to_string(
          array['initiative JSONB'] || array(
            select concat('"', characteristics.id::varchar, '" JSONB')
            from characteristics
            inner join focus_areas on characteristics.focus_area_id = focus_areas.id
            inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
            where focus_area_groups.scorecard_type = '#{scorecard.type}'
            order  by focus_areas.position, characteristics.position
          ), ', '
        )
      SQL
    end

    def crosstab_sql(scorecard, columns_data)
      <<~SQL
        select *
        from crosstab(
          $$
          select
            -- Key column
            jsonb_build_object(
              'id', initiatives.id,
              'name', initiatives.name,
              'subsystem_tags', array_agg(distinct initiatives_subsystem_tags.subsystem_tag_id)
            ) as initiative,
            -- Catgegory column
            characteristics.id,
            -- Value column
            jsonb_build_object(
              'focus_area_id', characteristics.focus_area_id,
              'focus_area_group_id', focus_area_groups.id,
              'checklist_item_id', checklist_items.id,
              'characteristics_id', characteristics.id,
              'comment', checklist_items.comment,
              'name', characteristics.name,
              'status', checklist_items.status
            ) as checklist_item

          from checklist_items
          inner join characteristics on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on checklist_items.initiative_id = initiatives.id
          inner join focus_areas on characteristics.focus_area_id = focus_areas.id
          inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
          left join initiatives_subsystem_tags
            on initiatives.id = initiatives_subsystem_tags.initiative_id
          where initiatives.scorecard_id = #{scorecard.id}
          and initiatives.deleted_at is null
          group by initiatives.id, characteristics.id, checklist_items.id, focus_area_groups.id
          order by initiative
          $$,
          $$
            select id from scorecard_type_characteristics where scorecard_type = '#{scorecard.type}'
          $$
        ) as data(#{columns_data})
      SQL
    end
  end
end
