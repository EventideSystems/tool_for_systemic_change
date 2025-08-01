# frozen_string_literal: true

require 'benchmark'

# This class is responsible for generating the data required to render the Impact Card Grid
# rubocop:disable Metrics/ClassLength
class ScorecardGrid
  class << self
    def execute(scorecard, snapshot_at = nil, subsystem_tags = []) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      columns_data = column_data(scorecard.workspace, scorecard.data_model_id)

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
              'subsystem_tags', array_agg(distinct initiatives_subsystem_tags.subsystem_tag_id),
              'subsystem_tag_names', array_agg(distinct subsystem_tags.name)
            ) as initiative,
            -- Catgegory column
            characteristics.id,
            -- Value column
            jsonb_build_object(
              'focus_area_id', characteristics.focus_area_id,
              'focus_area_name', focus_areas.name,
              'focus_area_color', focus_areas.color,
              'focus_area_position', focus_areas.position,
              'focus_area_group_id', focus_area_groups.id,
              'focus_area_group_position', focus_area_groups.position,
              'checklist_item_id', checklist_items.id,
              'characteristics_id', characteristics.id,
              'characteristics_position', characteristics.position,
              'comment', checklist_items.comment,
              'name', characteristics.name,
              'status', checklist_items.status
            ) as checklist_item

          from checklist_items
          inner join characteristics on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on checklist_items.initiative_id = initiatives.id
          inner join focus_areas on characteristics.focus_area_id = focus_areas.id
          inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
          inner join data_models on focus_area_groups.data_model_id = data_models.id
          left join initiatives_subsystem_tags
            on initiatives.id = initiatives_subsystem_tags.initiative_id
          left join subsystem_tags
            on initiatives_subsystem_tags.subsystem_tag_id = subsystem_tags.id
          where checklist_items.deleted_at is null
          and initiatives.scorecard_id = #{scorecard.id}
          and initiatives.deleted_at is null
          and (initiatives.archived_on is null or initiatives.archived_on > now())
          and data_models.workspace_id = #{scorecard.workspace_id}
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
            focus_areas.color,
            focus_area_groups.position,
            focus_areas.position,
            characteristics.position
          order by initiative, focus_area_groups.position, focus_areas.position, characteristics.position
          $$,
          $$
            select id from scorecard_type_characteristics where data_model_id = '#{scorecard.data_model_id}' and workspace_id = #{scorecard.workspace_id}
          $$
        ) as data(#{columns_data})
        order by lower(trim(initiative->>'name'))
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
              'subsystem_tags', array_agg(distinct initiatives_subsystem_tags.subsystem_tag_id),
              'subsystem_tag_names', array_agg(distinct subsystem_tags.name)
            ) as initiative,
            -- Catgegory column
            characteristics.id,
            -- Value column
            jsonb_build_object(
              'focus_area_id', characteristics.focus_area_id,
              'focus_area_name', focus_areas.name,
              'focus_area_color', focus_areas.color,
              'focus_area_position', focus_areas.position,
              'focus_area_group_id', focus_area_groups.id,
              'focus_area_group_position', focus_area_groups.position,
              'checklist_item_id', checklist_items.id,
              'characteristics_id', characteristics.id,
              'characteristics_position', characteristics.position,
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
          inner join data_models on focus_area_groups.data_model_id = data_models.id
          left join initiatives_subsystem_tags
            on initiatives.id = initiatives_subsystem_tags.initiative_id
          left join subsystem_tags
            on initiatives_subsystem_tags.subsystem_tag_id = subsystem_tags.id
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
          and data_models.workspace_id = #{scorecard.workspace_id}
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
            focus_areas.color,
            changes.comment,
            checklist_items_at_snap_shot.comment,
            changes.ending_status,
            checklist_items_at_snap_shot.status,
            focus_area_groups.position,
            focus_areas.position,
            characteristics.position
          order by initiative, focus_area_groups.position, focus_areas.position, characteristics.position
          $$,
          $$
            select id from scorecard_type_characteristics where data_model_id = '#{scorecard.data_model_id}' and workspace_id = #{scorecard.workspace_id}
          $$
        ) as data(#{columns_data})
        order by lower(trim(initiative->>'name'))
      SQL
    end

    def columns_data_sql(workspace, data_model_id)
      <<~SQL
        select
          array_to_string(
          array['initiative JSONB'] || array(
            select concat('"', characteristics.id::varchar, '" JSONB')
            from characteristics
            inner join focus_areas on characteristics.focus_area_id = focus_areas.id
            inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
            inner join data_models on focus_area_groups.data_model_id = data_models.id
            where focus_area_groups.data_model_id = '#{data_model_id}'
            and data_models.workspace_id = #{workspace.id}
            and focus_area_groups.deleted_at is null
            and focus_areas.deleted_at is null
            and characteristics.deleted_at is null
            order by focus_area_groups.position, focus_areas.position, characteristics.position
          ), ', '
        )
      SQL
    end

    def column_data(workspace, data_model_id)
      ActiveRecord::Base.connection.execute(columns_data_sql(workspace, data_model_id)).values.first.first
    end

    # NOTE: This is no longer required as we filter the subsystem tags in UI via JS now
    def subsystem_sql(subsystem_tags)
      return '' if subsystem_tags.blank?

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
