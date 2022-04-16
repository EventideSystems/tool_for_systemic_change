# frozen_string_literal: true

class SynchronizeLinkedScorecard
  class << self
    def call(source_scorecard, linked_initiative_names)
      if source_scorecard.linked_scorecard.blank?
        unlink(source_scorecard)
        return
      end

      target_scorecard = source_scorecard.linked_scorecard

      synchronize_initiatives(source_scorecard, target_scorecard, linked_initiative_names)

      source_initiatives = source_scorecard.initiatives.where(name: linked_initiative_names).sort_by(&:name)
      target_initiatives = target_scorecard.initiatives.where(name: linked_initiative_names).sort_by(&:name)

      source_scorecard.save!
      target_scorecard.save!

      source_initiatives.each_with_index do |source_itinerary, index|
        target_itinerary = target_initiatives[index]

        ::SynchronizeLinkedInitiative.call(source_itinerary, target_itinerary)
      end
    end

    def synchronize_initiatives(source_scorecard, target_scorecard, linked_initiative_names)
      source_initiative_names = source_scorecard.initiatives.where(name: linked_initiative_names).pluck(:name)
      target_initiative_names = target_scorecard.initiatives.where(name: linked_initiative_names).pluck(:name)

      missing_from_source = target_initiative_names - source_initiative_names
      missing_from_target = source_initiative_names - target_initiative_names

      target_scorecard.initiatives.where(name: missing_from_source).each do |initiative|
        source_scorecard.initiatives << initiative.dup
      end

      source_scorecard.initiatives.where(name: missing_from_target).each do |initiative|
        target_scorecard.initiatives << initiative.dup
      end

      source_scorecard.initiatives.where(name: linked_initiative_names).update_all(linked: true)
      target_scorecard.initiatives.where(name: linked_initiative_names).update_all(linked: true)

      source_scorecard.initiatives.where.not(name: linked_initiative_names).update_all(linked: false)
      target_scorecard.initiatives.where.not(name: linked_initiative_names).update_all(linked: false)
    end

    def unlink(source_scorecard)
      target_scorecard = Scorecard.find_by(linked_scorecard_id: source_scorecard.id)

      return if target_scorecard.blank?

      source_scorecard.initiatives.update_all(linked: false)
      target_scorecard.initiatives.update_all(linked: false)

      source_scorecard.linked_scorecard_id = nil
      target_scorecard.linked_scorecard_id = nil

      source_scorecard.save!
      target_scorecard.save!
    end
  end
end
