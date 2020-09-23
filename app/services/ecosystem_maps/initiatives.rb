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
      query = <<~SQL
        SELECT DISTINCT io1.initiative_id, io2.initiative_id
        FROM initiatives_organisations io1
        INNER JOIN initiatives_organisations io2 
        ON io2.organisation_id = io1.organisation_id
        INNER JOIN initiatives i1 
        ON i1.id = io1.initiative_id AND i1.deleted_at IS NULL
        INNER JOIN initiatives i2 
        ON i2.id = io2.initiative_id AND i2.deleted_at IS NULL
        WHERE io1.initiative_id <> io2.initiative_id
        AND i1.scorecard_id = #{transition_card.id}
        AND i2.scorecard_id = #{transition_card.id}
      SQL

      results = ActiveRecord::Base.connection.exec_query(query).rows

      results.map do |result|
        { 
          id: result.first,
          target: result.first, 
          source: result.second, 
          strength: 1
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
