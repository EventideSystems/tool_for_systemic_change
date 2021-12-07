# frozen_string_literal: true

class TransitionCardChecklistItems
  class << self
    def execute(transition_card_id, date_from, date_to)
      fetch_transition_card_initiatives_totals(transition_card_id, date_from, date_to)
    end

    private

    def bind_vars(transition_card_id, date_from, date_to)
      [
        ActiveRecord::Relation::QueryAttribute.new('date_from', date_from, ActiveRecord::Type::DateTime.new),
        ActiveRecord::Relation::QueryAttribute.new('date_to', date_to, ActiveRecord::Type::DateTime.new),
        ActiveRecord::Relation::QueryAttribute.new('transition_card_id', transition_card_id,
                                                   ActiveRecord::Type::Integer.new)
      ]
    end

    def calc_final_count_at_end_of_period(data)
      data[:checked_count_before_period] +
        data[:checked_count_during_period] -
        data[:unchecked_count_during_period]
    end

    def fetch_transition_card_initiatives_totals(transition_card_id, date_from, date_to)
      ApplicationRecord.connection.exec_query(
        TOTAL_TRANSITION_CARD_INITIATIVES_SQL,
        '-- TOTAL_TRANSITION_CARD_INITIATIVES_SQL --',
        bind_vars(transition_card_id, date_from, date_to),
        prepare: true
      ).map do |data|
        data.symbolize_keys!
        data[:final_count_at_end_of_period] = calc_final_count_at_end_of_period(data)

        data
      end
    end

    TOTAL_TRANSITION_CARD_INITIATIVES_SQL = <<~SQL
      with checked_status_before_period as (
        select
          focus_area_group_id,
          focus_area_id,
          characteristic_id,
          sum(case when to_status = 'checked' then 1 else 0 end) as checked_count
        from (
          select
            distinct on (focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id)
            focus_area_groups.id as focus_area_group_id,
            focus_areas.id as focus_area_id,
            characteristics.id as characteristic_id,
            initiatives.id as initiative_id,
            events_checklist_item_checkeds.occurred_at,
            events_checklist_item_checkeds.to_status
          from characteristics
          inner join focus_areas on focus_areas.id = characteristics.focus_area_id
          inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
          inner join checklist_items on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join events_checklist_item_checkeds
            on events_checklist_item_checkeds.checklist_item_id = checklist_items.id
            and events_checklist_item_checkeds.occurred_at < $1
            and events_checklist_item_checkeds.to_status in ('checked', 'unchecked')
          where initiatives.scorecard_id = $3
          and initiatives.deleted_at is null
          order by focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id, events_checklist_item_checkeds.occurred_at asc
        ) as checked_status_before_period
        group by focus_area_group_id, focus_area_id, characteristic_id
      ),

      checked_status_during_period as (
        select
          focus_area_group_id,
          focus_area_id,
          characteristic_id,
          sum(case when to_status = 'checked' then 1 else 0 end) as checked_count,
          sum(case when to_status = 'unchecked' then 1 else 0 end) as unchecked_count
        from (
          select
            distinct on (focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id)
            focus_area_groups.id as focus_area_group_id,
            focus_areas.id as focus_area_id,
            characteristics.id as characteristic_id,
            initiatives.id as initiative_id,
            events_checklist_item_checkeds.occurred_at,
            events_checklist_item_checkeds.to_status
          from characteristics
          inner join focus_areas on focus_areas.id = characteristics.focus_area_id
          inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
          inner join checklist_items on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join events_checklist_item_checkeds
            on events_checklist_item_checkeds.checklist_item_id = checklist_items.id
            and events_checklist_item_checkeds.occurred_at >= $1
            and events_checklist_item_checkeds.occurred_at <= $2
            and events_checklist_item_checkeds.to_status in ('checked', 'unchecked')
          where initiatives.scorecard_id = $3
          and initiatives.deleted_at is null
          order by focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id, events_checklist_item_checkeds.occurred_at asc
        ) as checked_status_during_period
        group by focus_area_group_id, focus_area_id, characteristic_id
      ),

      new_actual_comments_during_period as (
        select
          focus_area_group_id,
          focus_area_id,
          characteristic_id,
          sum(case when to_status = 'actual' then 1 else 0 end) as actual_count
        from (
          select
            distinct on (
              focus_area_groups.id, 
              focus_areas.id, 
              characteristics.id, 
              initiatives.id,
              checklist_items.id
            )
            focus_area_groups.id as focus_area_group_id,
            focus_areas.id as focus_area_id,
            characteristics.id as characteristic_id,
            initiatives.id as initiative_id,
            events_checklist_item_new_comments.occurred_at,
            events_checklist_item_new_comments.to_status
          from characteristics
          inner join focus_areas on focus_areas.id = characteristics.focus_area_id
          inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
          inner join checklist_items on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join events_checklist_item_new_comments
            on events_checklist_item_new_comments.checklist_item_id = checklist_items.id
            and events_checklist_item_new_comments.occurred_at >= $1
            and events_checklist_item_new_comments.occurred_at <= $2
            and events_checklist_item_new_comments.to_status = 'actual'
          where initiatives.scorecard_id = $3
          and initiatives.deleted_at is null
          order by 
            focus_area_groups.id, 
            focus_areas.id, 
            characteristics.id, 
            initiatives.id, 
            checklist_items.id, 
            events_checklist_item_new_comments.occurred_at asc
        ) as comments_during_period
        group by focus_area_group_id, focus_area_id, characteristic_id
      )

      select
        focus_area_groups.name as focus_area_group_name,
        focus_areas.name as focus_area_name,
        characteristics.name as characteristic_name,
        checked_status_before_period.checked_count as checked_count_before_period,
        checked_status_during_period.checked_count as checked_count_during_period,
        checked_status_during_period.unchecked_count as unchecked_count_during_period,
        new_actual_comments_during_period.actual_count as new_actual_comment_count_during_period
      from checked_status_before_period
      left join checked_status_during_period
        on checked_status_before_period.focus_area_group_id = checked_status_during_period.focus_area_group_id
        and checked_status_before_period.focus_area_id = checked_status_during_period.focus_area_id
        and checked_status_before_period.characteristic_id = checked_status_during_period.characteristic_id
      left join new_actual_comments_during_period
        on new_actual_comments_during_period.focus_area_group_id = checked_status_during_period.focus_area_group_id
        and new_actual_comments_during_period.focus_area_id = checked_status_during_period.focus_area_id
        and new_actual_comments_during_period.characteristic_id = checked_status_during_period.characteristic_id
      inner join characteristics on characteristics.id = checked_status_before_period.characteristic_id
      inner join focus_areas on focus_areas.id = characteristics.focus_area_id
      inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
      order by focus_area_groups.position, focus_areas.position, characteristics.position
    SQL
  end
end
