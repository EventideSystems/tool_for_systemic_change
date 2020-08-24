module EcosystemMaps
  class Initiatives
    attr_reader :transition_card
    
    def initialize(transition_card)
      @transition_card = transition_card
    end

    def nodes
      color_index = -1
      transition_card.initiatives.map do |initiative|
        color_index += 1
        { 
          id: initiative.id,
          initiative_name: initiative.name,
          initiative_description: initiative.description,
          partnering_organisation_names: initiative.organisations.map(&:name),
          subsystem_tag_names: initiative.subsystem_tags.map(&:name),
          initiative_started_at: initiative.started_at,
          initiative_finished_at: initiative.finished_at,
          group: 0, 
          label: initiative.name, 
          color: next_color(color_index)
        }
      end
    end

    def links
      initiative_ids = transition_card.initiatives.pluck(:id).to_a.join(',')
      
      query = <<~SQL
        SELECT initiatives_organisations.initiative_id, io.initiative_id
        FROM initiatives_organisations
        INNER JOIN initiatives_organisations io 
        ON initiatives_organisations.initiative_id <> io.initiative_id
        AND initiatives_organisations.organisation_id = io.organisation_id
        WHERE initiatives_organisations.initiative_id IN (#{initiative_ids})
        AND io.initiative_id IN (#{initiative_ids})
      SQL

      results = ActiveRecord::Base.connection.exec_query(query).rows

      (results + results.map{ |r| [r[1], r[0]] }).uniq.map do |result|
        { 
            id: result.first,
            target: result.first, 
            source: result.second, 
            strength: 0.1
        }
      end
    end

    private

    COLORS = %w[
      #FF0000 
      #F7C80B
      #FF6D24
      #7993F2
      #2E74BA
      #009BCC
      #008C8C
      #00CCAA
      #1CB85D    
    ]

    private_constant :COLORS

    def next_color(color_index)
      COLORS[color_index % COLORS.length]
    end

  end


end
