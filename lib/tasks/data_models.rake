# frozen_string_literal: true

namespace :data_models do # rubocop:disable Metrics/BlockLength
  namespace :system do # rubocop:disable Metrics/BlockLength
    desc 'Import SDG indicators from unstats.un.org'
    task import_sdgs: :environment do # rubocop:disable Metrics/BlockLength
      simple_data_model = DataModel.where(system_model: true).find_or_create_by(name: 'Sustainable Development Goals and Targets') do |model| # rubocop:disable Layout/LineLength
        model.description = 'Two-level SDGs data model, focusing on Goals and Targets'
        model.system_model = true
      end
      simple_data_model.save!

      FocusAreaGroup.upsert( # rubocop:disable Rails/SkipsModelValidations
        {
          impact_card_data_model_id: simple_data_model.id,
          name: 'SDGs Goals',
          description: 'Sustainable Development Goals',
          code: 'SDG'
        },
        unique_by: %i[code impact_card_data_model_id]
      )

      simple_data_model_group = simple_data_model.focus_area_groups.find_by(code: 'SDG')

      # deep_data_model = DataModel.where(system_model: true).find_or_create_by(name: 'Sustainable Development Goals, Targets and Indicators') do |model| # rubocop:disable Layout/LineLength
      #   model.description = 'Three-level SDGs data model, focusing on Goals, Targets and Indicators'
      #   model.system_model = true
      # end
      # deep_data_model.save!

      api = Gateways::SdgApi.new

      goals = api.fetch_goals
      targets = api.fetch_targets
      #  indicators = api.fetch_indicators

      goals.each do |goal|
        simple_data_model_area_ids = FocusArea.upsert( # rubocop:disable Rails/SkipsModelValidations
          {
            focus_area_group_id: simple_data_model_group.id,
            name: goal['title'],
            description: goal['description'],
            code: goal['code']
          },
          unique_by: %i[code focus_area_group_id],
          returning: %i[id]
        )

        targets.select { |t| t['goal'] == goal['code'] }.each do |target|
          Characteristic.upsert( # rubocop:disable Rails/SkipsModelValidations
            {
              focus_area_id: simple_data_model_area_ids.first,
              name: target['title'],
              description: target['description'],
              code: target['code']
            },
            unique_by: %i[code focus_area_id]
          )
        end

        # FocusAreaGroup.upsert(
        #   {
        #     impact_card_data_model_id: deep_data_model.id,
        #     name: goal['title'],
        #     description: goal['description'],
        #     code: goal['code']
        #   },
        #   unique_by: %i[code impact_card_data_model_id]
        # )
      end
      # targets = api.fetch_targets
      # indicators = api.fetch_indicators

      # puts "Fetched #{indicators.size} indicators, #{goals.size} goals, and #{targets.size} targets from SDG API."
      # puts "Importing #{indicators.size} indicators, #{goals.size} goals, and #{targets.size} targets into the database." # rubocop:disable Layout/LineLength
    end
  end
end
