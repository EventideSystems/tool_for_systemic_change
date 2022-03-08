# frozen_string_literal: true

class ScorecardGrid
  class << self
    def execute(scorecard, snapshot_at = nil, subsystem_tags = [])
      query = crosstab_sql(scorecard, wrap_date(snapshot_at), subsystem_tags)

      results = ActiveRecord::Base.connection.execute(query)

      results.map do |result|
        result
          .deep_transform_values { |v| JSON.parse(v) if v.present? }
          .select { |_k, v| v.present? }
      rescue TypeError => e
        Rails.logger.error e.message
        Rails.logger.error result.inspect
        raise
      end
    end

    private

    def results_columns(scorecard_type)
      ['initiative JSONB']
        .concat(characteristics_columns(scorecard_type))
        .join(',')
    end

    # NOTE: Equivalent SQL
    #   select string_agg('"'|| characteristics.id::varchar || '"' || ' JSONB', ', ' order by focus_areas.position, characteristics.position) as characteristics
    #   from characteristics
    #   inner join focus_areas on characteristics.focus_area_id = focus_areas.id
    #   inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
    #   where focus_area_groups.scorecard_type = 'SustainableDevelopmentGoalAlignmentCard'
    def characteristics_columns(scorecard_type)
      Characteristic
        .per_scorecard_type(scorecard_type)
        .order('focus_areas.position', 'characteristics.position')
        .map do |characteristic|
          "\"#{characteristic.id}\" JSONB"
        end
    end

    def crosstab_sql(scorecard, snapshot_at, subsystem_tags)
      <<~SQL
          select *
          from crosstab(
            $$
            with most_recent_activities as (
              select distinct on (checklist_item_id)
                events_checklist_item_activities.checklist_item_id,
                events_checklist_item_activities.to_status,
                events_checklist_item_activities.comment,
                events_checklist_item_activities.occurred_at
              from events_checklist_item_activities
              inner join checklist_items on events_checklist_item_activities.checklist_item_id = checklist_items.id
              inner join initiatives on checklist_items.initiative_id = initiatives.id
              where initiatives.scorecard_id = #{scorecard.id}
              and events_checklist_item_activities.occurred_at < #{snapshot_at}
              order by checklist_item_id, occurred_at desc
            )

            select
              -- Key column
              jsonb_build_object(
                'id', initiatives.id,
                'name', initiatives.name
              ) as initiative,
              -- Catgegory column
              characteristics.id,
              -- Value column
              jsonb_build_object(
                'focus_area_id', characteristics.focus_area_id,
                'focus_area_group_id', focus_area_groups.id,
                'checklist_item_id', most_recent_activities.checklist_item_id,
                'characteristics_id', characteristics.id,
                'comment', most_recent_activities.comment,
                'name', characteristics.name,
                'status', most_recent_activities.to_status
              ) as checklist_item

            from checklist_items
            inner join characteristics on checklist_items.characteristic_id = characteristics.id
            inner join initiatives on checklist_items.initiative_id = initiatives.id
            inner join focus_areas on characteristics.focus_area_id = focus_areas.id
            inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
            inner join most_recent_activities on most_recent_activities.checklist_item_id = checklist_items.id
            where initiatives.scorecard_id = #{scorecard.id}
            #{subsystem_sql(subsystem_tags)}
            order by initiative
            $$,
            $$
              select id from scorecard_type_characteristics where scorecard_type = '#{scorecard.type}'
            $$
          ) as data(#{results_columns(scorecard.type)}
        )
      SQL
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

    def wrap_date(snapshot_at)
      return 'now()' if snapshot_at.blank?

      snapshot_timestamp = snapshot_at.is_a?(String) ? Time.parse(snapshot_at) : snapshot_at.to_time
      "'#{snapshot_timestamp.utc.to_s(:db)}'"
    end
  end
end
