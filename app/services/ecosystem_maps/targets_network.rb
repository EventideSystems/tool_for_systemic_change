# frozen_string_literal: true

module EcosystemMaps
  class TargetsNetwork
    attr_reader :transition_card, :targets_network_mappings

    def initialize(transition_card)
      @transition_card = transition_card
    end

    def links
      TargetsNetworkMapping.all.map do |mapping|
        {
          id: mapping.id,
          target: "characteristic-#{mapping.characteristic_id}",
          source: "focus-area-#{mapping.focus_area_id}"
        }
      end
    end

    # TODO: Add orgs to the nodes via the transition_card
    def nodes
      focus_area_nodes + characteristic_nodes
    end

    private

    def focus_area_nodes
      FocusArea.where(id: TargetsNetworkMapping.pluck(:focus_area_id).uniq).map do |node|
        mappings = organisations_and_intitiatives.select do |mapping|
          mapping[:focus_area_id] == node.id
        end

        organisation_ids = mappings.map { |hash| hash[:organisation_id] }.flatten.compact.uniq.map(&:to_s)
        initiative_ids = mappings.map { |hash| hash[:initiative_id] }.flatten.compact.uniq.map(&:to_s)

        {
          id: "focus-area-#{node.id}",
          label: node.short_name,
          color: node.actual_color,
          organisation_ids: organisation_ids,
          initiative_ids: initiative_ids,
          size: 10
        }
      end
    end

    def characteristic_nodes
      Characteristic.where(id: TargetsNetworkMapping.pluck(:characteristic_id).uniq).map do |node|
        mappings = organisations_and_intitiatives.select do |mapping|
          mapping[:characteristic_id] == node.id
        end

        organisation_ids = mappings.map { |hash| hash[:organisation_id] }.flatten.compact.uniq.map(&:to_s)
        initiative_ids = mappings.map { |hash| hash[:initiative_id] }.flatten.compact.uniq.map(&:to_s)

        {
          id: "characteristic-#{node.id}",
          label: node.short_name,
          color: node.focus_area.actual_color,
          characteristic_id: node.id,
          organisation_ids: organisation_ids,
          initiative_ids: initiative_ids,
          size: 6
        }
      end
    end

    def organisations_and_intitiatives
      @organisations_and_intitiatives ||= ActiveRecord::Base.connection.execute(
        <<~SQL
          select distinct on (checklist_item_id)
            events_checklist_item_activities.checklist_item_id as checklist_item_id,
            characteristics.id as characteristic_id,
            characteristics.focus_area_id as focus_area_id,
            array_agg(initiatives.id) as initiative_id,
            array_agg(initiatives_organisations.organisation_id) as organisation_id
          from events_checklist_item_activities
          inner join checklist_items on checklist_items.id = events_checklist_item_activities.checklist_item_id
          inner join characteristics on characteristics.id = checklist_items.characteristic_id
          inner join initiatives on initiatives.id = checklist_items.initiative_id
          left join initiatives_organisations
          on initiatives_organisations.initiative_id = initiatives.id
          where events_checklist_item_activities.to_status = 'actual'
          and initiatives.scorecard_id = #{transition_card.id}
          group by checklist_item_id, characteristics.id
        SQL
      ).map do |row|
        row.symbolize_keys.transform_values { |v| v.is_a?(String) ? v.gsub(/{|}/, '').split(',') : v }
      end
    end
  end
end
