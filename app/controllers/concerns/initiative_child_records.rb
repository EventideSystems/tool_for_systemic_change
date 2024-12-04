# frozen_string_literal: true

# Shared methods for managing initiative child records (e.g. organisations, subsystem tags, etc.)
module InitiativeChildRecords
  extend ActiveSupport::Concern

  def update_stakeholders!(initiative, params)
    update_child_records!(
      initiative,
      params[:initiatives_organisations_attributes],
      :organisation_id,
      initiative.organisation_ids,
      initiative.initiatives_organisations
    )
  end

  def update_subsystem_tags!(initiative, params)
    update_child_records!(
      initiative,
      params[:initiatives_subsystem_tags_attributes],
      :subsystem_tag_id,
      initiative.subsystem_tag_ids,
      initiative.initiatives_subsystem_tags
    )
  end

  private

  def deletable_and_creatable_ids(attributes, id_key, current_ids)
    new_ids = attributes.values.map { |attr| attr[id_key] }.map(&:to_i).uniq

    deletable_ids = current_ids - new_ids
    creatable_ids = new_ids - current_ids

    [deletable_ids, creatable_ids]
  end

  def update_child_records!(initiative, attributes, id_key, current_ids, association)
    return if attributes.blank?

    deletable_ids, creatable_ids = deletable_and_creatable_ids(attributes, id_key, current_ids)

    association.where(id_key => deletable_ids).destroy_all
    creatable_ids.each do |new_id|
      association.create(id_key => new_id)
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create #{id_key}: #{e.message}"
    end

    Rails.logger.info "Updated #{id_key.to_s.pluralize} for initiative #{initiative.id}: added #{creatable_ids}, removed #{deletable_ids}" # rubocop:disable Layout/LineLength
  end
end
