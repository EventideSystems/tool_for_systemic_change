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

    # TODO Add orgs to the nodes via the transition_card
    def nodes
      focus_area_nodes + characteristic_nodes
    end

    private

    def focus_area_nodes
      FocusArea.where(id: TargetsNetworkMapping.pluck(:focus_area_id).uniq).map do |node|

        binding.pry
        mappings = organisations_and_intitiatives.select do |mapping|
          mapping[:focus_area_id] == node.id
        end

        organisation_ids = mappings.map{ |hash| hash[:organisation_ids] }.flatten.uniq
        initiative_ids = mappings.map{ |hash| hash[:initiative_ids] }.flatten.uniq

        {
          id: "focus-area-#{node.id}",
          label: node.short_name,
          color: node.actual_color,
          organisation_ids: organisation_ids,
          initiative_ids: initiative_ids,
          size: 10,
        }
      end
    end

    def characteristic_nodes
      Characteristic.where(id: TargetsNetworkMapping.pluck(:characteristic_id).uniq).map do |node|

        mappings = organisations_and_intitiatives.select do |mapping|
          mapping[:characteristic_id] == node.id
        end

        organisation_ids = mappings.map{ |hash| hash[:organisation_ids] }.flatten.uniq
        initiative_ids = mappings.map{ |hash| hash[:initiative_ids] }.flatten.uniq

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

    def organisation_ids


    def organisations_and_intitiatives
      @organisations_and_intitiatives ||= ActiveRecord::Base.connection.execute(
        <<~SQL
          with current_checklist_items as (
            select distinct on (checklist_item_id)
              events_checklist_item_activities.checklist_item_id as checklist_item_id,
              characteristics.id as characteristic_id,
              initiatives.id as initiative_id
            from events_checklist_item_activities
            inner join checklist_items on checklist_items.id = events_checklist_item_activities.checklist_item_id
            inner join characteristics on characteristics.id = checklist_items.characteristic_id
            inner join initiatives on initiatives.id = checklist_items.initiative_id
            where events_checklist_item_activities.to_status = 'actual'
            and initiatives.scorecard_id = #{transition_card.id}
          )
          select
            targets_network_mappings.*,
            array_agg(initiatives.id) as initiative_ids,
            array_agg(initiatives_organisations.organisation_id) as organisation_ids
          from targets_network_mappings
          inner join current_checklist_items
            on targets_network_mappings.characteristic_id = current_checklist_items.characteristic_id
          inner join initiatives
            on initiatives.id = current_checklist_items.initiative_id
          inner join initiatives_organisations
            on initiatives_organisations.initiative_id = initiatives.id
          group by
            targets_network_mappings.id,
            targets_network_mappings.focus_area_id,
            targets_network_mappings.characteristic_id
        SQL
      ).map do |row|
        {
          id: row['id'],
          focus_area_id: row['focus_area_id'],
          characteristic_id: row['characteristic_id'],
          initiative_ids: row['initiative_ids'].gsub(/{|}/, '').split(',').uniq,
          organisation_ids: row['organisation_ids'].gsub(/{|}/, '').split(',').uniq
        }
      end
    end
  end
end
