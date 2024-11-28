module ImpactCards
  # This service is used to merge two impact cards into one. The initiatives from the other impact card are copied to the
  # target impact card, and the other impact card is deleted. When copying initiatives with the same name, a synthetic
  # history is generated that consolidates the changes from both.
  class DeepMerge
    attr_accessor :impact_card, :other_impact_card

    def self.call(impact_card:, other_impact_card:)
      new(impact_card:, other_impact_card:).call
    end

    def initialize(impact_card:, other_impact_card:)
      @impact_card = impact_card
      @other_impact_card = other_impact_card
    end

    def call
      assert_valid_merge!

      ActiveRecord::Base.transaction do
        merge_non_clashing_initiatives
        merge_clashing_initiatives
        delete_other_impact_card
      end

      impact_card.initiatives.reload
      impact_card.reload
    end

    private

    def assert_valid_merge!
      unless impact_card.account == other_impact_card.account
        raise(ArgumentError, 'Impact cards must be in the same account')
      end

      raise(ArgumentError, 'Impact cards must be the same type') unless impact_card.type == other_impact_card.type
    end

    def calc_new_activity_for_addition(previous_change)
      previous_change.present? && previous_change.activity == 'addition' ? 'none' : 'addition'
    end

    def calc_new_activity_for_new_comments_saved_assigned_actuals(previous_change, current_change)
      if previous_change.nil? || previous_change.ending_status == 'actual'
        'new_comments_saved_assigned_actuals'
      else
        current_change.ending_status == 'actual' && previous_change.ending_status != 'actual' ? 'addition' : 'none'
      end
    end

    def delete_other_impact_card
      impact_card.update(linked_scorecard_id: nil) if impact_card.linked_scorecard_id == other_impact_card.id
      other_impact_card.delete
    end

    def fetch_combined_changes(checklist_item, other_checklist_item)
      ChecklistItemChange
        .where(checklist_item:)
        .or(ChecklistItemChange.where(checklist_item: other_checklist_item))
        .order(created_at: :asc)
    end

    def merge_clashing_initiatives
      other_initiative_names = other_impact_card.initiatives.pluck(:name)
      clashing_initiatives = impact_card.initiatives.where(name: other_initiative_names)

      clashing_initiatives.each do |initiative|
        other_initiative = other_impact_card.initiatives.find_by(name: initiative.name)

        merge_initiatives(initiative, other_initiative)

        initiative.checklist_items.each do |checklist_item|
          other_checklist_item = other_initiative.checklist_items.find { |other| other.name == checklist_item.name }

          combined_changes = fetch_combined_changes(checklist_item, other_checklist_item)

          previous_change = nil

          combined_changes.each do |change|
            {}.then do |attrs|
              attrs[:starting_status] = previous_change.ending_status if previous_change
              attrs[:checklist_item] = checklist_item if change.checklist_item == other_checklist_item
              attrs[:activity] =
                case change.activity
                when 'addition'
                  calc_new_activity_for_addition(previous_change)
                when 'new_comments_saved_assigned_actuals'
                  calc_new_activity_for_new_comments_saved_assigned_actuals(previous_change, change)
                else
                  'none'
                end

              change.update!(attrs)
            end

            previous_change = change
          end

          last_checklist_item_change = checklist_item.checklist_item_changes.last

          next if last_checklist_item_change.blank?

          checklist_item.update!(
            user: last_checklist_item_change.user,
            comment: last_checklist_item_change.comment,
            status: last_checklist_item_change.ending_status
          )
        end
      end
    end

    # Merge the other initiative into the target initiative. The target initiative is updated with the latest
    # information from the two initiatives.
    def merge_initiatives(initiative, other_initiative) # rubocop:disable Metrics/MethodLength
      canonical_initiative = [initiative, other_initiative].max_by(&:updated_at)

      return if initiative == canonical_initiative

      merge_stakeholders(initiative, other_initiative)
      merge_subsystem_tags(initiative, other_initiative)

      initiative.update(
        updated_at: canonical_initiative.updated_at,
        description: canonical_initiative.description,
        started_at: canonical_initiative.started_at,
        finished_at: canonical_initiative.finished_at,
        dates_confirmed: canonical_initiative.dates_confirmed,
        contact_name: canonical_initiative.contact_name.presence || initiative.contact_name,
        contact_email: canonical_initiative.contact_email.presence || initiative.contact_email,
        contact_phone: canonical_initiative.contact_phone.presence || initiative.contact_phone,
        contact_website: canonical_initiative.contact_website.presence || initiative.contact_website,
        contact_position: canonical_initiative.contact_position.presence || initiative.contact_position
      )
    end

    # Merge initiatives from the other impact card that do not clash with existing initiatives by retargetting
    # them directly to the impact card.
    def merge_non_clashing_initiatives
      existing_initiative_names = impact_card.initiatives.pluck(:name)
      non_clashing_other_initiatives = other_impact_card.initiatives.where.not(name: existing_initiative_names)

      non_clashing_other_initiatives.update_all(scorecard_id: impact_card.id)
      other_impact_card.reload
    end

    def merge_stakeholders(initiative, other_initiative)
      initiative.organisations << (other_initiative.organisations - initiative.organisations)
      initiative.save!
    end

    def merge_subsystem_tags(initiative, other_initiative)
      initiative.subsystem_tags << (other_initiative.subsystem_tags - initiative.subsystem_tags)
      initiative.save!
    end
  end
end