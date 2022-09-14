# frozen_string_literal: true

class InsertChecklistItemChangesForOldItems < ActiveRecord::Migration[7.0]
  def up
    execute INSERT_CHECKLIST_ITEM_CHANGES_SQL
  end

  def down
    # NO OP
  end

  INSERT_CHECKLIST_ITEM_CHANGES_SQL = <<~SQL
    insert into checklist_item_changes (
      checklist_item_id,
      user_id,
      starting_status,
      ending_status,
      comment,
      action,
      activity,
      created_at
    )
    select distinct changes.* from (
      select
        checklist_items.id as checklist_item_id,
        item_versions.whodunnit::integer as user_id,
        case
          when previous_version.object is null then 'no_comment'
          else 'more_information'
        end as starting_status,
        case
          when next_version.object is null
          then coalesce(closest_change.starting_status, 'more_information')
          else 'more_information'
        end as ending_status,
        item_versions.object->>'comment' as comment,
        case
        when previous_version.object is null then 'save_new_comment'
        else 'update_existing'
        end as action,
        case
        when next_version.object is null
        then (
          case closest_change.starting_status
          when 'actual' then 'addition'
          else 'none'
          end
        )
        else 'none'
        end as activity,
        (item_versions.object->>'updated_at')::timestamp without time zone as created_at
      from checklist_items
      inner join initiatives on initiatives.id = checklist_items.initiative_id
      inner join versions item_versions
        on checklist_items.id = item_versions.item_id
        and item_versions.item_type = 'ChecklistItem'
      left join checklist_item_comments
        on checklist_item_comments.checklist_item_id = checklist_items.id
      left join versions comment_versions
        on checklist_item_comments.id = comment_versions.item_id
        and comment_versions.item_type = 'ChecklistItemComment'
      left join lateral (
        select
          distinct on (previous_version.item_id)
          previous_version.object,
          previous_version.created_at
        from versions previous_version
          where previous_version.item_id = item_versions.item_id
          and previous_version.created_at < item_versions.created_at
          and previous_version.object->>'comment' is not null
          and previous_version.object->>'comment' <> ''
          order by previous_version.item_id, previous_version.created_at desc
      ) previous_version on true
      left join lateral (
        select
          distinct on (next_version.item_id)
          next_version.object,
          next_version.created_at
        from versions next_version
          where next_version.item_id = item_versions.item_id
          and next_version.created_at > item_versions.created_at
          and next_version.object->>'comment' is not null
          and next_version.object->>'comment' <> ''
          order by next_version.item_id, next_version.created_at asc
      ) next_version on true
      left join lateral (
        select
          distinct on (closest_change.checklist_item_id)
          closest_change.starting_status,
          closest_change.created_at
        from checklist_item_changes closest_change
          where closest_change.checklist_item_id = item_versions.item_id
          and closest_change.created_at > item_versions.created_at
          order by closest_change.checklist_item_id, closest_change.created_at asc
      ) closest_change on true
      where item_versions.object->>'comment' is not null
      and item_versions.object->>'comment' is not null
      and item_versions.object->>'comment' <> ''
      order by item_versions.created_at
      ) changes
  SQL

end
