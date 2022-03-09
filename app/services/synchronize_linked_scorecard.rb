class SynchronizeLinkedScorecard
  class << self
    def call(source_scorecard)
      return if source_scorecard.linked_scorecard.blank?

      target_scorecard = source_scorecard.linked_scorecard

      synchronize_initiatives(source_scorecard, target_scorecard)

      source_initiatives = source_scorecard.initiatives.sort_by(&:name)
      target_initiatives = target_scorecard.initiatives.sort_by(&:name)

      source_scorecard.save!
      target_scorecard.save!

      source_initiatives.each_with_index do |source_itinerary, index|
        target_itinerary = target_initiatives[index]

        SynchronizeLinkedItinerary.call(source_itinerary, target_itinerary)
      end
    end

    def synchronize_initiatives(source_scorecard, target_scorecard)
      source_initiative_names = source_scorecard.initiatives.pluck(:name)
      target_initiative_names = target_scorecard.initiatives.pluck(:name)

      missing_from_source = target_initiative_names - source_initiative_names
      missing_from_target = source_initiative_names - target_initiative_names

      target_scorecard.initiatives.where(name: missing_from_source).each do |initiative|
        source_scorecard.initiatives << initiative.dup
      end

      source_scorecard.initiatives.where(name: missing_from_target).each do |initiative|
        target_scorecard.initiatives << initiative.dup
      end
    end

  end
end
