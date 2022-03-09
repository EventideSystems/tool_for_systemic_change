class SynchronizeLinkedItinerary
  class << self
    def call(source_itinerary, target_itinerary=nil)
      return if source_itinerary.scorecard.linked_scorecard.blank?

      target_itinerary = target_itinerary || fetch_target_itinerary(source_itinerary)

      update_initiative_attributes(source_itinerary, target_itinerary)
      synchronize_initiative_organisations(source_itinerary, target_itinerary)
      synchronize_initiative_subsystems_tags(source_itinerary, target_itinerary)

      source_itinerary.save!
      target_itinerary.save!
    end

    private

    def build_new_itinerary(source_itinerary)
      Itinerary.new.tap do |itinerary|
        update_initiative_attributes(source_itinerary, new_itinerary)
      end
    end

    def fetch_target_itinerary(source_itinerary)
      target_scorecard = source_itinerary.scorecard.linked_scorecard

      target_scorecard.initiatives.find_by(name: source_itinerary.name) || build_new_itinerary(source_itinerary).tap do |itinerary|
        target_scorecard.initiatives << itinerary
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
      if initiative_1.updated_at > initiative_2.updated_at || initiative_2.new_record?
        source_initiative = initiative_1
        target_initiative = initiative_2
      else
        source_initiative = initiative_2
        target_initiative = initiative_1
      end

      source_attributes = \
        source_initiative
          .attributes
          .except(*%w[id name scorecard_id created_at deleted_at updated_at old_notes])
          .select { |_, v| v.present? }

      target_initiative.assign_attributes(source_attributes)
      target_initiative.notes = source_initiative.notes if target_initiative.notes.present?
    end
  end
end
