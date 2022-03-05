# frozen_string_literal: true

class ScorecardCopier
  def initialize(source, target_name, deep_copy: false)
    @source = source
    @target_name = target_name
    @deep_copy = deep_copy
  end

  def perform
    target = source.dup

    ActiveRecord::Base.transaction do
      PaperTrail.enabled = false

      target.name = target_name || "Copy of #{source.name}"
      target.shared_link_id = source.new_shared_link_id
      target.save!

      source_initiative_ids,
      target_initiative_ids = copy_initiatives(source.id, target.id)

      source_checklist_items_ids,
      target_checklist_items_ids = copy_checklist_items(source_initiative_ids, target_initiative_ids)

      copy_initiative_organisations(source_initiative_ids, target_initiative_ids)

      if deep_copy
        source_checklist_item_comment_ids,
        target_checklist_item_comment_ids = copy_checklist_item_comments(source_checklist_items_ids,
                                                                         target_checklist_items_ids)

        copy_paper_trail_records('Scorecard', [source.id], [target.id])
        copy_paper_trail_records('Initiative', source_initiative_ids, target_initiative_ids)
        copy_paper_trail_records('ChecklistItem', source_checklist_items_ids, target_checklist_items_ids)
        copy_paper_trail_records('ChecklistItemComment', source_checklist_item_comment_ids,
                                 target_checklist_item_comment_ids)
      end
    ensure
      PaperTrail.enabled = true
    end

    target
  end

  private

  attr_reader :source, :target_name, :deep_copy

  def copy_initiatives(source_scorecard_id, target_scorecard_id)
    insert_query = "
    INSERT INTO initiatives (name, description, scorecard_id, started_at, finished_at, dates_confirmed, contact_name, contact_email, contact_phone, contact_website, contact_position, deleted_at, created_at, updated_at)
      SELECT name, description, #{target_scorecard_id}, started_at, finished_at, dates_confirmed, contact_name, contact_email, contact_phone, contact_website, contact_position, deleted_at, created_at, updated_at
      FROM initiatives
      WHERE scorecard_id = #{source_scorecard_id}
      ORDER BY id
    RETURNING id;
    "

    select_query = "
    SELECT id
    FROM initiatives
    WHERE scorecard_id = #{source.id}
    ORDER BY id
    "

    source_ids = ActiveRecord::Base.connection.execute(select_query).values.flatten
    target_ids = ActiveRecord::Base.connection.execute(insert_query).values.flatten

    [source_ids, target_ids]
  end

  def copy_initiative_organisations(source_initiative_ids, target_initiative_ids)
    case_fragment = build_case_fragment(
      'initiatives_organisations.initiative_id',
      source_initiative_ids,
      target_initiative_ids
    )

    insert_query = "
    INSERT INTO initiatives_organisations (initiative_id, organisation_id, deleted_at, created_at, updated_at)
      SELECT #{case_fragment}, organisation_id, deleted_at, created_at, updated_at
      FROM initiatives_organisations
      WHERE initiative_id IN (#{source_initiative_ids.join(',')})
      ORDER BY id
    RETURNING id;
    "

    ActiveRecord::Base.connection.execute(insert_query)
  end

  def copy_checklist_items(source_initiative_ids, target_initiative_ids)
    case_fragment = build_case_fragment(
      'checklist_items.initiative_id',
      source_initiative_ids,
      target_initiative_ids
    )

    insert_query = "
    INSERT INTO checklist_items (checked, comment, characteristic_id, initiative_id, created_at, updated_at)
      SELECT #{deep_copy ? 'checked, comment' : 'NULL, NULL'}, characteristic_id, #{case_fragment}, created_at, updated_at
      FROM checklist_items
      WHERE initiative_id IN (#{source_initiative_ids.join(',')})
      ORDER BY id
    RETURNING id;
    "

    select_query = "
    SELECT id
    FROM checklist_items
    WHERE initiative_id IN (#{source_initiative_ids.join(',')})
    ORDER BY id
    "

    source_ids = ActiveRecord::Base.connection.execute(select_query).values.flatten
    target_ids = ActiveRecord::Base.connection.execute(insert_query).values.flatten

    [source_ids, target_ids]
  end

  def copy_checklist_item_comments(source_checklist_items_ids, target_checklist_items_ids)
    case_fragment = build_case_fragment(
      'checklist_item_comments.checklist_item_id',
      source_checklist_items_ids,
      target_checklist_items_ids
    )

    insert_query = "
    INSERT INTO checklist_item_comments (comment, status, checklist_item_id, deleted_at, created_at, updated_at)
      SELECT comment, status, #{case_fragment}, deleted_at, created_at, updated_at
      FROM checklist_item_comments
      WHERE checklist_item_id IN (#{source_checklist_items_ids.join(',')})
      ORDER BY id
    RETURNING id;
    "

    select_query = "
    SELECT id
    FROM checklist_item_comments
    WHERE checklist_item_id IN (#{source_checklist_items_ids.join(',')})
    ORDER BY id
    "

    source_ids = ActiveRecord::Base.connection.execute(select_query).values.flatten
    target_ids = ActiveRecord::Base.connection.execute(insert_query).values.flatten

    [source_ids, target_ids]
  end

  def copy_paper_trail_records(item_type, source_ids, target_ids)
    case_fragment = build_case_fragment(
      'versions.item_id',
      source_ids,
      target_ids
    )

    insert_query = "
    INSERT INTO versions (item_type, item_id, event, whodunnit, object, created_at)
      SELECT item_type, #{case_fragment}, event, whodunnit, object, created_at
      FROM versions
      WHERE item_type = '#{item_type}' AND item_id IN (#{source_ids.join(',')})
    RETURNING id;
    "

    ActiveRecord::Base.connection.execute(insert_query)
  end

  def build_case_fragment(field_name, source_ids, target_ids)
    case_fragment = "CASE #{field_name}\n"
    source_ids.each_with_index do |source_id, index|
      case_fragment += "WHEN #{source_id} THEN #{target_ids[index]}\n"
    end
    case_fragment += "END\n"

    case_fragment
  end

  def deep_copy_paper_trail_records(source, target)
    PaperTrail::Version.where(
      item_type: 'Scorecard',
      item_id: target.id
    ).delete_all

    query = "
    INSERT INTO versions (item_type, item_id, event, whodunnit, object, created_at)
      SELECT item_type, '#{target.id}', event, whodunnit, object, created_at
      FROM versions
      WHERE item_type = 'Scorecard' AND item_id = #{source.id}
    RETURNING id;
    "

    ActiveRecord::Base.connection.execute(query)
  end
end
