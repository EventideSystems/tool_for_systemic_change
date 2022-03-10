module EcosystemMaps

  class TargetsNetwork

    attr_reader :transition_card

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
        {
          id: "focus-area-#{node.id}",
          label: node.name,
          color: node.actual_color,
        }
      end
    end

    def characteristic_nodes
      Characteristic.where(id: TargetsNetworkMapping.pluck(:characteristic_id).uniq).map do |node|
        {
          id: "characteristic-#{node.id}",
          label: node.name,
          color: node.focus_area.actual_color,
        }
      end
    end
  end
end
