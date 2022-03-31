module EcosystemMaps

  class TargetsNetwork

    attr_reader :transition_card, :targets_network_mappings

    def initialize(transition_card)
      @transition_card = transition_card
    end

    def links
      targets_network_mappings.map do |mapping|
        {
          id: mapping.id,
          target: "characteristic-#{mapping.characteristic_id}",
          source: "focus-area-#{mapping.focus_area_id}",
        }
      end
    end

    def nodes
      focus_area_nodes + characteristic_nodes
    end

    private

    def focus_area_nodes
      targets_network_mappings.includes(:focus_area).group_by(&:focus_area_id).map do |focus_area_id, mappings|
        {
          id: "focus-area-#{focus_area_id}",
          focus_area_id: focus_area_id,
          label: mappings.first.focus_area.short_name,
          color: mappings.first.focus_area.actual_color,
          organisation_ids: mappings.map(&:organisation_ids).flatten.uniq,
          initiative_ids: mappings.map(&:initiative_ids).flatten.uniq,
          size: 10
        }
      end
    end

    def characteristic_nodes
      targets_network_mappings.includes(characteristic: :focus_area).group_by(&:characteristic_id).map do |characteristic_id, mappings|
        {
          id: "characteristic-#{characteristic_id}",
          characteristic_id: characteristic_id,
          label: mappings.first.characteristic.short_name,
          color: mappings.first.characteristic.focus_area.actual_color,
          organisation_ids: mappings.map(&:organisation_ids).flatten.uniq,
          initiative_ids: mappings.map(&:initiative_ids).flatten.uniq,
          size: 6
        }
      end
    end

    # TODO: Need to check which characteristcs have checklist items with at least one
    # 'actual' comment in the same focus_area
    # <<~SQL
    select focus_areas.name, characteristics.name from checklist_items
    inner join characteristics
      on characteristics.id = checklist_items.characteristic_id
    inner join focus_areas
      on focus_areas.id = characteristics.focus_area_id
      and focus_areas.id in (
        select focus_area_id from focus_areas focus_areas_with_comments
        inner join characteristics characteristics_with_comments
          on characteristics_with_comments.focus_area_id = focus_areas_with_comments.id
        inner join checklist_items checklist_items_with_comments
          on checklist_items_with_comments.characteristic_id = characteristics_with_comments.id
        inner join checklist_item_comments
          on checklist_item_comments.checklist_item_id = checklist_items_with_comments.id
          and checklist_item_comments.status = 'actual'
        where focus_areas_with_comments.id = focus_areas.id
      )
    # SQL

    def targets_network_mappings
      @targets_network_mappings ||= TargetsNetworkMapping.select(
        <<~SELECT
          distinct on (targets_network_mappings.id)
            targets_network_mappings.*,
            array_remove(
              array_agg(
                initiatives_organisations.organisation_id
              ), null
            ) as organisation_ids,
            array_remove(
              array_agg(initiatives_organisations.initiative_id), null
            ) as initiative_ids
        SELECT
        ).joins(
        <<~JOINS
          left join checklist_items
            on targets_network_mappings.characteristic_id = checklist_items.characteristic_id
          inner join initiatives
            on initiatives.scorecard_id = #{transition_card.id}
            and checklist_items.initiative_id = initiatives.id
          left join initiatives_organisations
            on initiatives_organisations.initiative_id = initiatives.id
          JOINS
        ).group('targets_network_mappings.id').order('targets_network_mappings.id')
    end
  end
end
