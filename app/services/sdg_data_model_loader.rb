# frozen_string_literal: true

# SDG Data Model Loader, responsible for loading system-level SDG data models.
# This service interacts with the SDG API to fetch data and populate the database.
#
# @example
#   loader = SdgDataModelLoader.new
#   loader.load_data_models
#
# @see Gateways::SdgApi
# @see FocusAreaGroup
# @see FocusArea
# @see Indicator
class SdgDataModelLoader # rubocop:disable Metrics/ClassLength
  def self.call
    new.call
  end

  def initialize
    @sdg_api = Gateways::SdgApi.new
    @sdg_i18n = Gateways::SdgI18n.new
  end

  def call
    fetch_source_data
    load_two_tier_sdg_data_model
    load_three_tier_sdg_data_model
  end

  TWO_TIER_SDG_DATA_MODEL_NAME = 'Sustainable Development Goals and Targets'
  THREE_TIER_SDG_DATA_MODEL_NAME = 'Sustainable Development Goals, Targets and Indicators'

  private

  attr_reader :sdg_api, :sdg_i18n, :sdg_goals, :sdg_targets, :sdg_indicators, :sdg_goal_translations

  SDG_GOAL_COLORS = {
    '1' => '#E5243B',
    '2' => '#DDA63A',
    '3' => '#4C9F38',
    '4' => '#C5192D',
    '5' => '#FF3A21',
    '6' => '#26BDE2',
    '7' => '#FCC30B',
    '8' => '#A21942',
    '9' => '#FD6925',
    '10' => '#DD1367',
    '11' => '#FD9D24',
    '12' => '#BF8B2E',
    '13' => '#3F7E44',
    '14' => '#0A97D9',
    '15' => '#56C02B',
    '16' => '#00689D',
    '17' => '#19486A'
  }.freeze

  def fetch_source_data
    @sdg_goals = sdg_api.fetch_goals
    @sdg_targets = sdg_api.fetch_targets
    @sdg_indicators = sdg_api.fetch_indicators
    @sdg_goal_translations = sdg_i18n.fetch_goals_and_targets
  end

  def load_two_tier_sdg_data_model # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    ActiveRecord::Base.transaction do # rubocop:disable Metrics/BlockLength
      data_model = \
        DataModel
        .where(system_model: true)
        .find_or_create_by(name: TWO_TIER_SDG_DATA_MODEL_NAME) do |model|
          model.description = 'Two-tier SDGs data model, focusing on Goals and Targets'
          model.system_model = true
          model.save!
        end

      goal = data_model.focus_area_groups.where(name: 'SDGs Targets').first_or_create do |group|
        group.name = 'SDGs Targets'
        group.position = 0
        group.save!
      end

      goal.focus_areas.update_all(position: nil) # rubocop:disable Rails/SkipsModelValidations

      sdg_goals.each do |sdg_goal| # rubocop:disable Metrics/BlockLength
        FocusArea.upsert( # rubocop:disable Rails/SkipsModelValidations
          {
            focus_area_group_id: goal.id,
            name: sdg_goal['title'],
            short_name: sdg_goal_translation_short_name(sdg_goal['code']),
            description: sdg_goal['description'],
            code: sdg_goal['code'],
            color: sdg_goal_color(sdg_goal['code']),
            position: sdg_goal['code'].to_i
          },
          unique_by: %i[code focus_area_group_id],
          returning: %i[id]
        )

        target = goal.focus_areas.find_by(code: sdg_goal['code'])

        sdg_targets.select { |t| t['goal'] == sdg_goal['code'] }.each do |sdg_target|
          Characteristic.upsert( # rubocop:disable Rails/SkipsModelValidations
            {
              focus_area_id: target.id,
              name: sdg_target['title'],
              short_name: sdg_target_translation_short_name(sdg_goal['code'], sdg_target['code']),
              description: sdg_target['description'],
              code: sdg_target['code']
            },
            unique_by: %i[code focus_area_id]
          )
        end

        target.characteristics.update_all(position: nil) # rubocop:disable Rails/SkipsModelValidations
        target.characteristics.reload.sort_by do |characteristic|
          characteristic.code.split('.').last
        end.each_with_index do |characteristic, index| # rubocop:disable Style/MultilineBlockChain
          characteristic.update(position: index)
          characteristic.save!
        end
      end
    end
  end

  def load_three_tier_sdg_data_model # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
    ActiveRecord::Base.transaction do # rubocop:disable Metrics/BlockLength
      data_model = \
        DataModel
        .where(system_model: true)
        .find_or_create_by(name: THREE_TIER_SDG_DATA_MODEL_NAME) do |model|
          model.description = 'Three-tier SDGs data model, expanded to Goals, Targets and Indicators'
          model.system_model = true
          model.save!
        end

      data_model.focus_area_groups.update_all(position: nil) # rubocop:disable Rails/SkipsModelValidations

      sdg_goals.each do |sdg_goal| # rubocop:disable Metrics/BlockLength
        FocusAreaGroup.upsert( # rubocop:disable Rails/SkipsModelValidations
          {
            data_model_id: data_model.id,
            name: sdg_goal['title'],
            short_name: sdg_goal_translation_short_name(sdg_goal['code']),
            description: sdg_goal['description'],
            code: sdg_goal['code'],
            color: sdg_goal_color(sdg_goal['code']),
            position: sdg_goal['code'].to_i
          },
          unique_by: %i[code data_model_id],
          returning: %i[id]
        )

        goal = data_model.focus_area_groups.find_by(code: sdg_goal['code'])

        sdg_targets.select { |t| t['goal'] == sdg_goal['code'] }.each do |sdg_target| # rubocop:disable Metrics/BlockLength
          FocusArea.upsert( # rubocop:disable Rails/SkipsModelValidations
            {
              focus_area_group_id: goal.id,
              name: sdg_target['title'],
              short_name: sdg_target_translation_short_name(sdg_goal['code'], sdg_target['code']),
              description: sdg_target['description'],
              color: sdg_goal_color(sdg_goal['code']),
              code: sdg_target['code']
            },
            unique_by: %i[code focus_area_group_id],
            returning: %i[id]
          )

          target = goal.focus_areas.find_by(code: sdg_target['code'])

          sdg_indicators.select { |i| i['target'] == sdg_target['code'] }.each do |sdg_indicator|
            Characteristic.upsert( # rubocop:disable Rails/SkipsModelValidations
              {
                focus_area_id: target.id,
                name: sdg_indicator['description'],
                code: sdg_indicator['code']
              },
              unique_by: %i[code focus_area_id]
            )
          end

          target.characteristics.update_all(position: nil) # rubocop:disable Rails/SkipsModelValidations
          target.characteristics.reload.sort_by(&:code).each_with_index do |indicator, index|
            indicator.update(position: index)
            indicator.save!
          end
        end
      end
    end
  end

  def sdg_goal_color(code)
    SDG_GOAL_COLORS[code] || '#000000'
  end

  def sdg_goal_translation_short_name(code)
    sdg_goal_translations.dig(code, 'short_title')
  end

  def sdg_target_translation_short_name(goal_code, code)
    sdg_goal_translations.dig(goal_code, 'targets', code, 'short_title')
  end
end
