# frozen_string_literal: true

class SynchronizeLinkedInitiative
  class << self
    def call(source_initiative, target_initiative = nil)
      return if source_initiative.scorecard.linked_scorecard.blank?
      return if source_initiative.archived?

      target_initiative ||= fetch_target_initiative(source_initiative)
      return if target_initiative.archived?

      update_initiative_attributes(source_initiative, target_initiative)
      synchronize_initiative_organisations(source_initiative, target_initiative)
      synchronize_initiative_subsystems_tags(source_initiative, target_initiative)

      source_initiative.save!
      target_initiative.save!
    end

    private

    def build_new_initiative(source_initiative)
      Initiative.new.tap do |new_initiative|
        update_initiative_attributes(source_initiative, new_initiative)
      end
    end

    def fetch_target_initiative(source_initiative)
      target_scorecard = source_initiative.scorecard.linked_scorecard

      target_scorecard.initiatives.find_by(name: source_initiative.name) || build_new_initiative(source_initiative).tap do |initiative|
        target_scorecard.initiatives << initiative
      end
    end

    def synchronize_initiative_organisations(source_initiative, target_initiative)
      source_organisations = source_initiative.organisations
      target_organisations = target_initiative.organisations

      missing_from_source = target_organisations - source_organisations
      missing_from_target = source_organisations - target_organisations

      source_initiative.organisations << missing_from_source if missing_from_source.present?
      target_initiative.organisations << missing_from_target if missing_from_target.present?
    end

    def synchronize_initiative_subsystems_tags(source_initiative, target_initiative)
      source_subsystem_tags = source_initiative.subsystem_tags
      target_subsystem_tags = target_initiative.subsystem_tags

      missing_from_source = target_subsystem_tags - source_subsystem_tags
      missing_from_target = source_subsystem_tags - target_subsystem_tags

      source_initiative.subsystem_tags << missing_from_source if missing_from_source.present?
      target_initiative.subsystem_tags << missing_from_target if missing_from_target.present?
    end

    def update_initiative_attributes(initiative_1, initiative_2)
      if initiative_2.new_record? || initiative_1.updated_at > initiative_2.updated_at
        source_initiative = initiative_1
        target_initiative = initiative_2
      else
        source_initiative = initiative_2
        target_initiative = initiative_1
      end

      source_initiative.update(linked: true)

      source_attributes = \
        source_initiative
        .attributes
        .except(*%w[id scorecard_id created_at deleted_at updated_at old_notes linked])
        .select { |_, v| v.present? }

      target_initiative.assign_attributes(source_attributes)
      target_initiative.notes = source_initiative.notes if target_initiative.notes.present?
    end
  end
end
