# frozen_string_literal: true

require 'benchmark'

# rubocop:disable Metrics/ClassLength
class ScorecardGrid
  class << self
    def execute(scorecard, snapshot_at = nil, subsystem_tags = [])
      columns_data = column_data(scorecard.account, scorecard.type) # ScorecardGridColumns::DATA[scorecard.type]

      if snapshot_at.present?
        ActiveRecord::Base
          .connection
          .execute(historical_crosstab_sql(scorecard, snapshot_at, columns_data, subsystem_tags))
          .map do |result|
            result.transform_values { |v| v.nil? ? {} : FastJsonparser.parse(v)  }
          end
      else
        ActiveRecord::Base
          .connection
          .execute(current_crosstab_sql(scorecard, columns_data, subsystem_tags))
          .map do |result|
            result.transform_values { |v| v.nil? ? {} : FastJsonparser.parse(v)  }
          end
      end
    end

    private

    def current_crosstab_sql(scorecard, columns_data, subsystem_tags)
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
              'focus_area_name', focus_areas.name,
              'focus_area_color', focus_areas.actual_color,
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
          where checklist_items.deleted_at is null
          and initiatives.scorecard_id = #{scorecard.id}
          and initiatives.deleted_at is null
          and (initiatives.archived_on is null or initiatives.archived_on > now())
          and focus_area_groups.account_id = #{scorecard.account_id}
          and focus_area_groups.deleted_at is null
          and focus_areas.deleted_at is null
          and characteristics.deleted_at is null
          #{subsystem_sql(subsystem_tags)}
          group by
            initiatives.id,
            characteristics.id,
            checklist_items.id,
            focus_area_groups.id,
            focus_areas.name,
            focus_areas.actual_color
          order by initiative
          $$,
          $$
            select id from scorecard_type_characteristics where scorecard_type = '#{scorecard.type}' and account_id = #{scorecard.account_id}
          $$
        ) as data(#{columns_data})
        order by initiative->>'name'
      SQL
    end

    def historical_crosstab_sql(scorecard, snapshot_at, columns_data, subsystem_tags)
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
              'focus_area_name', focus_areas.name,
              'focus_area_color', focus_areas.actual_color,
              'focus_area_group_id', focus_area_groups.id,
              'checklist_item_id', checklist_items.id,
              'characteristics_id', characteristics.id,
              'comment', coalesce(
                changes.comment,
                checklist_items_at_snap_shot.comment
              ),
              'name', characteristics.name,
              'status', coalesce(
                changes.ending_status,
                coalesce(checklist_items_at_snap_shot.status, 'no_comment')
              )
            ) as checklist_item
          from checklist_items
          inner join characteristics on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on checklist_items.initiative_id = initiatives.id
          inner join focus_areas on characteristics.focus_area_id = focus_areas.id
          inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
          left join initiatives_subsystem_tags
            on initiatives.id = initiatives_subsystem_tags.initiative_id
          left join checklist_items checklist_items_at_snap_shot
            on checklist_items_at_snap_shot.id = checklist_items.id
            and checklist_items_at_snap_shot.updated_at < #{wrap_date(snapshot_at)}
          left join (
            select
              changes.*,
              row_number() over (
                partition by changes.checklist_item_id order by changes.created_at desc
              ) as rn
              from checklist_item_changes changes
              where changes.created_at < #{wrap_date(snapshot_at)}
            ) changes on changes.checklist_item_id = checklist_items.id and rn = 1
          where checklist_items.deleted_at is null
          and initiatives.scorecard_id = #{scorecard.id}
          and initiatives.deleted_at is null
          and (initiatives.archived_on is null or initiatives.archived_on > #{wrap_date(snapshot_at)})
          and focus_area_groups.account_id = #{scorecard.account_id}
          and focus_area_groups.deleted_at is null
          and focus_areas.deleted_at is null
          and characteristics.deleted_at is null
          #{subsystem_sql(subsystem_tags)}
          group by
            initiatives.id,
            characteristics.id,
            checklist_items.id,
            focus_area_groups.id,
            focus_areas.name,
            focus_areas.actual_color,
            changes.comment,
            checklist_items_at_snap_shot.comment,
            changes.ending_status,
            checklist_items_at_snap_shot.status
          order by initiative
          $$,
          $$
            select id from scorecard_type_characteristics where scorecard_type = '#{scorecard.type}' and account_id = #{scorecard.account_id}
          $$
        ) as data(#{columns_data})
        order by initiative->>'name'
      SQL
    end

    def columns_data_sql(account, scorecard_type)
      <<~SQL
        select
          array_to_string(
          array['initiative JSONB'] || array(
            select concat('"', characteristics.id::varchar, '" JSONB')
            from characteristics
            inner join focus_areas on characteristics.focus_area_id = focus_areas.id
            inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
            where focus_area_groups.scorecard_type = '#{scorecard_type}'
            and focus_area_groups.account_id = #{account.id}
            and focus_area_groups.deleted_at is null
            and focus_areas.deleted_at is null
            and characteristics.deleted_at is null
            order by focus_areas.position, characteristics.position
          ), ', '
        )
      SQL
    end

    def column_data(account, scorecard_type)
      ActiveRecord::Base.connection.execute(columns_data_sql(account, scorecard_type)).values.first.first
    end

    def subsystem_sql(subsystem_tags)
      return '' if subsystem_tags.empty?

      subsystem_tags_ids = subsystem_tags.map(&:id)

      <<~SQL
        AND initiatives.id IN (
          SELECT initiative_id
          FROM initiatives_subsystem_tags
          WHERE subsystem_tag_id IN (#{subsystem_tags_ids.join(',')})
        )
      SQL
    end

    # NOTE: Copied from ScorecardGrid
    def wrap_date(snapshot_at)
      return 'now()' if snapshot_at.blank?

      snapshot_timestamp = snapshot_at.is_a?(String) ? Time.zone.parse(snapshot_at) : snapshot_at.to_time
      "'#{snapshot_timestamp.utc.to_fs(:db)}'"
    end
  end
end
# rubocop:enable Metrics/ClassLength
