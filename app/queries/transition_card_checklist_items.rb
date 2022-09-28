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

    # NOTE: Eventually we'll have to cater for "removals", but this has not been clearly
    # defined as yet under the new "changes" model.
    def calc_final_count_at_end_of_period(data)
      data[:actual_count_before_period] +
        data[:additions_count_during_period]
    end

    def fetch_transition_card_initiatives_totals(transition_card_id, date_from, date_to)
      ApplicationRecord.connection.exec_query(
        TOTAL_TRANSITION_CARD_INITIATIVES_SQL,
        '-- TOTAL_TRANSITION_CARD_INITIATIVES_SQL --',
        bind_vars(transition_card_id, date_from, date_to),
        prepare: true
      ).map do |data|
        data.symbolize_keys!
        data
      end
    end

    TOTAL_TRANSITION_CARD_INITIATIVES_SQL = <<~SQL

      with checklist_items_actual_status_before_period as (
        select
          focus_area_group_id,
          focus_area_id,
          characteristic_id,
          count(created_at) filter (where status = 'actual') as actual_count
        from (
          select
            distinct on (focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id)
            focus_area_groups.id as focus_area_group_id,
            focus_areas.id as focus_area_id,
            characteristics.id as characteristic_id,
            initiatives.id as initiative_id,
            checklist_item_changes.created_at,
            checklist_item_changes.ending_status as status
          from characteristics
          inner join focus_areas on focus_areas.id = characteristics.focus_area_id
          inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
          inner join checklist_items on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join checklist_item_changes
            on checklist_item_changes.checklist_item_id = checklist_items.id
            and checklist_item_changes.created_at < $1
          where initiatives.scorecard_id = $3
          and initiatives.deleted_at is null
          order by focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id, checklist_item_changes.created_at desc
        ) as checked_status_before_period
        group by focus_area_group_id, focus_area_id, characteristic_id
      ),

      checklist_items_actual_status_after_period as (
        select
          focus_area_group_id,
          focus_area_id,
          characteristic_id,
          count(created_at) filter (where status = 'actual') as actual_count
        from (
          select
            distinct on (focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id)
            focus_area_groups.id as focus_area_group_id,
            focus_areas.id as focus_area_id,
            characteristics.id as characteristic_id,
            initiatives.id as initiative_id,
            checklist_item_changes.created_at,
            checklist_item_changes.ending_status as status
          from characteristics
          inner join focus_areas on focus_areas.id = characteristics.focus_area_id
          inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
          inner join checklist_items on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join checklist_item_changes
            on checklist_item_changes.checklist_item_id = checklist_items.id
            and checklist_item_changes.created_at < $2
          where initiatives.scorecard_id = $3
          and initiatives.deleted_at is null
          order by focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id, checklist_item_changes.created_at desc
        ) as checked_status_before_period
        group by focus_area_group_id, focus_area_id, characteristic_id
      ),

      update_existing_additions as (
        select
          focus_area_group_id,
          focus_area_id,
          characteristic_id,
          count(created_at) as additions_count
        from (
          select
            distinct on (focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id)
            focus_area_groups.id as focus_area_group_id,
            focus_areas.id as focus_area_id,
            characteristics.id as characteristic_id,
            initiatives.id as initiative_id,
            checklist_item_changes.created_at
          from characteristics
          inner join focus_areas on focus_areas.id = characteristics.focus_area_id
          inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
          inner join checklist_items on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join checklist_item_changes
            on checklist_item_changes.checklist_item_id = checklist_items.id
            and checklist_item_changes.created_at >= $1
            and checklist_item_changes.created_at <= $2
            and checklist_item_changes.activity = 'addition'
            and checklist_item_changes.action = 'update_existing'
          where initiatives.scorecard_id = $3
          and initiatives.deleted_at is null
          order by focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id, checklist_item_changes.created_at asc
        ) as checked_status_during_period
        group by focus_area_group_id, focus_area_id, characteristic_id
      ),

      new_comment_additions as (
        select
          focus_area_group_id,
          focus_area_id,
          characteristic_id,
          count(created_at) as additions_count
        from (
          select
            distinct on (focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id, checklist_item_changes.created_at)
            focus_area_groups.id as focus_area_group_id,
            focus_areas.id as focus_area_id,
            characteristics.id as characteristic_id,
            initiatives.id as initiative_id,
            checklist_item_changes.created_at
          from characteristics
          inner join focus_areas on focus_areas.id = characteristics.focus_area_id
          inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
          inner join checklist_items on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join checklist_item_changes
            on checklist_item_changes.checklist_item_id = checklist_items.id
            and checklist_item_changes.created_at >= $1
            and checklist_item_changes.created_at <= $2
            and checklist_item_changes.activity = 'addition'
            and checklist_item_changes.action = 'save_new_comment'
          where initiatives.scorecard_id = $3
          and initiatives.deleted_at is null
          order by focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id, checklist_item_changes.created_at asc
        ) as checked_status_during_period
        group by focus_area_group_id, focus_area_id, characteristic_id
      ),

      new_comments_saved_actuals_during_period as (
        select
          focus_area_group_id,
          focus_area_id,
          characteristic_id,
          count(created_at) as assigned_actuals_count
        from (
          select
            distinct on (focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id, checklist_item_changes.created_at)
            focus_area_groups.id as focus_area_group_id,
            focus_areas.id as focus_area_id,
            characteristics.id as characteristic_id,
            initiatives.id as initiative_id,
            checklist_item_changes.created_at
          from characteristics
          inner join focus_areas on focus_areas.id = characteristics.focus_area_id
          inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
          inner join checklist_items on checklist_items.characteristic_id = characteristics.id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join checklist_item_changes
            on checklist_item_changes.checklist_item_id = checklist_items.id
            and checklist_item_changes.created_at >= $1
            and checklist_item_changes.created_at <= $2
            and checklist_item_changes.activity = 'new_comments_saved_assigned_actuals'
          where initiatives.scorecard_id = $3
          and initiatives.deleted_at is null
          order by focus_area_groups.id, focus_areas.id, characteristics.id, initiatives.id, checklist_item_changes.created_at asc
        ) as checked_status_during_period
        group by focus_area_group_id, focus_area_id, characteristic_id
      )

      select
        focus_area_groups.name as focus_area_group_name,
        focus_areas.name as focus_area_name,
        characteristics.name as characteristic_name,
        checklist_items_actual_status_before_period.actual_count as actual_count_before_period,
        (new_comment_additions.additions_count + update_existing_additions.additions_count) as additions_count_during_period,
        new_comments_saved_actuals_during_period.assigned_actuals_count as assigned_actuals_count_during_period,
        checklist_items_actual_status_after_period.actual_count as actual_count_after_period
      from checklist_items_actual_status_before_period
      left join checklist_items_actual_status_after_period
        on checklist_items_actual_status_after_period.focus_area_group_id = checklist_items_actual_status_before_period.focus_area_group_id
        and checklist_items_actual_status_after_period.focus_area_id = checklist_items_actual_status_before_period.focus_area_id
        and checklist_items_actual_status_after_period.characteristic_id = checklist_items_actual_status_before_period.characteristic_id
      left join update_existing_additions
        on update_existing_additions.focus_area_group_id = checklist_items_actual_status_before_period.focus_area_group_id
        and update_existing_additions.focus_area_id = checklist_items_actual_status_before_period.focus_area_id
        and update_existing_additions.characteristic_id = checklist_items_actual_status_before_period.characteristic_id
      left join new_comment_additions
        on new_comment_additions.focus_area_group_id = checklist_items_actual_status_before_period.focus_area_group_id
        and new_comment_additions.focus_area_id = checklist_items_actual_status_before_period.focus_area_id
        and new_comment_additions.characteristic_id = checklist_items_actual_status_before_period.characteristic_id
      left join new_comments_saved_actuals_during_period
        on new_comments_saved_actuals_during_period.focus_area_group_id = checklist_items_actual_status_before_period.focus_area_group_id
        and new_comments_saved_actuals_during_period.focus_area_id = checklist_items_actual_status_before_period.focus_area_id
        and new_comments_saved_actuals_during_period.characteristic_id = checklist_items_actual_status_before_period.characteristic_id
      inner join characteristics on characteristics.id = checklist_items_actual_status_before_period.characteristic_id
      inner join focus_areas on focus_areas.id = characteristics.focus_area_id
      inner join focus_area_groups on focus_area_groups.id = focus_areas.focus_area_group_id
      order by focus_area_groups.position, focus_areas.position, characteristics.position
    SQL
  end
end
