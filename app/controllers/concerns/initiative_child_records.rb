# frozen_string_literal: true

# Shared methods for managing initiative child records (e.g. organisations, subsystem tags, etc.)
module InitiativeChildRecords
  extend ActiveSupport::Concern

  def update_stakeholders!(initiative, params)
    return if initiative.blank?

    organisation_ids = params[:initiatives_organisations_attributes].values.map do |org|
      org[:organisation_id]
    end.map(&:to_i).uniq

    current_organisation_ids = initiative.organisation_ids

    deleteable_organisation_ids = current_organisation_ids - organisation_ids
    createable_organisation_ids = organisation_ids - current_organisation_ids

    initiative.initiatives_organisations.where(organisation_id: deleteable_organisation_ids).destroy_all
    createable_organisation_ids.each do |organisation_id|
      initiative.initiatives_organisations.create(organisation_id: organisation_id)
    end
  end

  def update_subsystem_tags!(initiative, params)
    return if initiative.blank?

    subsystem_tag_ids = params[:initiatives_subsystem_tags_attributes].values.map do |org|
      org[:subsystem_tag_id]
    end.map(&:to_i).uniq

    current_subsystem_tag_ids = initiative.subsystem_tag_ids

    deleteable_subsystem_tag_ids = current_subsystem_tag_ids - subsystem_tag_ids
    createable_subsystem_tag_ids = subsystem_tag_ids - current_subsystem_tag_ids

    initiative.initiatives_subsystem_tags.where(subsystem_tag_id: deleteable_subsystem_tag_ids).destroy_all
    createable_subsystem_tag_ids.each do |subsystem_tag_id|
      initiative.initiatives_subsystem_tags.create(subsystem_tag_id: subsystem_tag_id)
    end
  end
end
