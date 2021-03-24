class TransitionCardSummary

  class << self

    def execute(transition_card, snapshot_at, subsystem_tags)
      query = select_sql(transition_card.id, snapshot_at, subsystem_tags)
      results = ActiveRecord::Base.connection.execute(query)

      results.map do |result|
        begin
          result.deep_transform_values{ |v| JSON.parse(v) if v.present? }
        rescue TypeError => e
          Rails.logger.error e.message
          Rails.logger.error result.inspect
          raise
        end
      end
    end

    private

    def final_result_sql
      ['initiative TEXT'].concat(
        Characteristic
          .joins(:focus_area)
          .order('focus_areas.position', 'characteristics.position')
          .map do |characteristic|
            "\"#{characteristic.id}\" JSONB"
          end
        ).join(',')
    end

    def subsystem_sql(subsystem_tags)
      return '' if subsystem_tags.empty?

      subsystem_tags_ids = subsystem_tags.map(&:id)

      <<~SQL
        AND initiatives.id IN (
          SELECT initiative_id 
          FROM initiatives_subsystem_tags 
          WHERE subsystem_tag_id IN (#{subsystem_tags_ids.join(',')})
        )
      SQL
    end

    def select_sql(transition_card_id, snapshot_at, subsystem_tags)
      snapshot_at_arg = snapshot_at.present? ? "'#{snapshot_at}'" : 'NULL'
      
      <<~SQL
        SELECT * 
        FROM crosstab(
        $$
          SELECT
          jsonb_build_object(
            'id', initiatives.id,
            'name', initiatives.name
          ) AS initiative,
          characteristics.id AS characteristic,
          jsonb_build_object(
            'name', characteristics.name,
            'checked', checklist_item_at_time(checklist_items.id, #{snapshot_at_arg})
          )
          FROM checklist_items
          INNER JOIN characteristics ON characteristics.id = checklist_items.characteristic_id
          INNER JOIN focus_areas ON focus_areas.id = characteristics.focus_area_id
          INNER JOIN initiatives 
            ON initiatives.id = checklist_items.initiative_id 
            AND initiatives.deleted_at IS NULL
          INNER JOIN scorecards ON scorecards.id = initiatives.scorecard_id
          WHERE scorecards.id = #{transition_card_id}
          #{subsystem_sql(subsystem_tags)}
          ORDER BY initiatives.name, focus_areas.position, characteristics.position
        $$,
        $$
          SELECT characteristics.id FROM characteristics 
          INNER JOIN focus_areas ON focus_areas.id = characteristics.focus_area_id
          ORDER BY focus_areas.position, characteristics.position
        $$
        )
        AS final_result(#{final_result_sql})
      SQL
    end
  end
end
