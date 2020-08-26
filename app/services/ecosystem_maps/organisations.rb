module EcosystemMaps
  class Organisations
    attr_reader :transition_card
    
    def initialize(transition_card)
      @transition_card = transition_card
    end

    def links
      grouped_link_data = link_data.group_by(&:itself).transform_values(&:count)
  
      upper = grouped_link_data.values.max
      lower = grouped_link_data.values.min
  
      grouped_link_data.map do |(target, source), link_count|
        { 
          id: target,
          target: target, 
          source: source, 
          strength: calc_strength(upper, lower, link_count) 
        }
      end
    end

    def nodes
      linked_data_ids = link_data.flatten.uniq
  
      nodes = transition_card.organisations.uniq
  
      nodes.map do |node|
        
        if node.id.in?(linked_data_ids)        
          cluster_node_ids = link_data.each_with_object([]) do |link, array|
            if node.id.in?(link)
              linked_id = link - [node.id]
              array.push(linked_id)
            end
          end.flatten.uniq
    
          initiative_names = []
          partnering_organisations = Organisation.where(id: cluster_node_ids)
          partnering_initiative_names = build_partnering_initiative_names(node.id, cluster_node_ids)
        else
          initiative_names = node
            .initiatives_organisations
            .joins(:initiative)
            .where('initiatives.scorecard_id = :scorecard_id', scorecard_id: transition_card.id)
            .to_a.map{ |i| i.initiative.name }
  
          partnering_organisations = []
          partnering_initiative_names = []
        end
  
        { 
          id: node.id,
          organisation_name: node.name,
          organisation_description: node.description,
          organisation_sector_name: node.sector&.name,
          organisation_weblink: node.weblink,
          partnering_initiative_names: partnering_initiative_names,
          initiative_names: initiative_names,
          partnering_organisation_names: partnering_organisations.map(&:name),
          group: 0, 
          label: node.name, 
          color: node.sector.color || '#000000'
        }
      end
    end

    private

    def build_link_data
      query = <<~SQL
        SELECT org1.id, org2.id 
        FROM initiatives
        INNER JOIN scorecards ON scorecards.id = initiatives.scorecard_id
        INNER JOIN initiatives_organisations io1 ON io1.initiative_id = initiatives.id
        INNER JOIN organisations org1 ON org1.id = io1.organisation_id
        INNER JOIN initiatives_organisations io2 ON io2.initiative_id = initiatives.id
        INNER JOIN organisations org2 ON org2.id = io2.organisation_id
        WHERE org1.id <> org2.id AND initiatives.scorecard_id = #{transition_card.id};
      SQL
  
      results = ActiveRecord::Base.connection.exec_query(query).rows
  
      results.map { |result| [result.min, result.max] }
    end

    def build_partnering_initiative_names(organisation_id, partnering_organisation_ids)
      query = <<~SQL
        SELECT DISTINCT(name) FROM initiatives
        INNER JOIN initiatives_organisations io1 
          ON io1.initiative_id = initiatives.id 
          AND io1.organisation_id = #{organisation_id}
        INNER JOIN initiatives_organisations io2 
          ON io2.initiative_id = initiatives.id 
          AND io2.organisation_id IN (#{partnering_organisation_ids.join(',')})
      SQL
  
      results = ActiveRecord::Base.connection.exec_query(query).rows
      
      results.flatten
    end

    def link_data
      @link_data ||= build_link_data
    end

    STRENGTH_ABS_LOWER = 0.01
    STRENGTH_ABS_UPPER = 0.49
  
    def calc_strength(upper, lower, value)    
      0.05
    end

  end
end
