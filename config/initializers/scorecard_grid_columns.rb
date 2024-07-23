# frozen_string_literal: true

module ScorecardGridColumns
  def self.columns_data_sql(scorecard_type)
    <<~SQL
      select
        array_to_string(
        array['initiative JSONB'] || array(
          select concat('"', characteristics.id::varchar, '" JSONB')
          from characteristics
          inner join focus_areas on characteristics.focus_area_id = focus_areas.id
          inner join focus_area_groups on focus_areas.focus_area_group_id = focus_area_groups.id
          where focus_area_groups.scorecard_type = '#{scorecard_type}'
          and focus_area_groups.deleted_at is null
          order  by focus_areas.position, characteristics.position
        ), ', '
      )
    SQL
  end

  def self.column_data(scorecard_type)
    ActiveRecord::Base.connection.execute(columns_data_sql(scorecard_type)).values.first.first
  end

  # rubocop:disable Style/StringHashKeys
  # rubocop:disable Style/ConstantVisibility
  DATA = {
    'TransitionCard' => column_data('TransitionCard'),
    'SustainableDevelopmentGoalAlignmentCard' => column_data('SustainableDevelopmentGoalAlignmentCard')
  }.freeze
  # rubocop:enable Style/StringHashKeys
  # rubocop:enable Style/ConstantVisibility
end
