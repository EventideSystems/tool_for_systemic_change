# frozen_string_literal: true

class InsertChecklistItemChanges < ActiveRecord::Migration[7.0]
  def up
    execute INSERT_CHECKLIST_ITEM_CHANGES_SQL
  end

  def down
    ChecklistItemChange.delete_all
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

    select
      checklist_item_comments.checklist_item_id as checklist_item_id,
      versions.whodunnit::integer as user_id,
      coalesce(prev_comment.status, 'no_comment') as starting_status,
      coalesce(next_version.object->>'status', checklist_item_comments.status) as ending_status,
       coalesce(next_version.object->>'comment', checklist_item_comments.comment) as comment,
      'save_new_comment' as action,
      case
      when
        coalesce(prev_comment.status, 'no_comment') <> 'actual'
        and coalesce(next_version.object->>'status', checklist_item_comments.status) = 'actual'
        then 'addition'
      when
        coalesce(prev_comment.status, 'no_comment') = 'actual'
        and coalesce(next_version.object->>'status', checklist_item_comments.status) = 'actual'
        and prev_comment.status is not null
        then 'new_comments_saved_assigned_actuals'
      else 'none' end as activity,
      coalesce((next_version.object->>'updated_at')::timestamp without time zone, checklist_item_comments.updated_at) as created_at
    from versions
    inner join checklist_item_comments on checklist_item_comments.id = versions.item_id
    inner join checklist_items on checklist_items.id = checklist_item_comments.checklist_item_id
    left join lateral (
    select
      distinct on (item_id)
      next_versions.item_id,
      next_versions.object
    from versions next_versions
    where next_versions.created_at > versions.created_at
    and next_versions.item_type = 'ChecklistItemComment'
    and next_versions.event = 'update'
    and next_versions.item_id = versions.item_id
    order by item_id, created_at asc
    ) as next_version on true
    left join lateral (
    select
      distinct on (checklist_item_id)
      prev_comments.id,
      prev_comments.status
    from checklist_item_comments prev_comments
    where prev_comments.checklist_item_id = checklist_item_comments.checklist_item_id
    and prev_comments.updated_at < checklist_item_comments.created_at
    order by checklist_item_id, created_at desc
    ) as prev_comment on true
    where item_type = 'ChecklistItemComment'
    and event = 'create'

    union

    select
      checklist_item_comments.checklist_item_id as checklist_item_id,
      versions.whodunnit::integer as user_id,
      versions.object->>'status' as starting_status,
      coalesce(next_version.object->>'status', checklist_item_comments.status) as ending_status,
      coalesce(next_version.object->>'comment', checklist_item_comments.comment) as comment,
      'update_existing' as action,
      case
      when
        versions.object->>'status' <> 'actual'
        and coalesce(next_version.object->>'status', checklist_item_comments.status) = 'actual'
        then 'addition'
      else 'none' end as activity,
      coalesce((next_version.object->>'updated_at')::timestamp without time zone, checklist_item_comments.updated_at) as created_at
    from checklist_item_comments
    inner join versions
    on versions.item_type = 'ChecklistItemComment'
    and versions.event = 'update'
    and versions.item_id = checklist_item_comments.id
    inner join checklist_items on checklist_items.id = checklist_item_comments.checklist_item_id
    left join lateral (
    select
      distinct on (item_id)
      next_versions.item_id,
      next_versions.object
    from versions next_versions
    where next_versions.created_at > versions.created_at
    and next_versions.item_type = 'ChecklistItemComment'
    and next_versions.event = 'update'
    and next_versions.item_id = versions.item_id
    order by item_id, created_at asc
    ) as next_version on true

    order by created_at asc
  SQL
end
