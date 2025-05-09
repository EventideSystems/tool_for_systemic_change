# frozen_string_literal: true

module DataModels
  # Save data model to YAML file
  class Export
    attr_reader :data_model, :filename

    def initialize(data_model:, filename:)
      @filename = filename
      @data_model = data_model
    end

    def self.call(data_model:, filename:)
      new(data_model:, filename:).call
    end

    def call
      build_data_model_hash.merge(goals: build_goals_hash).tap do |data_model_hash|
        File.open(filename, 'w') do |file|
          file.write(data_model_hash.to_yaml)
        end
      end
    end

    private

    def build_data_model_hash
      {
        name: data_model.name,
        short_name: data_model.short_name,
        description: data_model.description,
        author: data_model.author,
        license: data_model.license
      }.compact.transform_values(&:strip)
    end

    def build_goals_hash # rubocop:disable Metrics/MethodLength
      data_model.focus_area_groups.order(:position).map do |goal|
        build_element_hash(goal).merge(
          targets: goal.focus_areas.order(:position).map do |target|
            build_element_hash(target).merge(
              indicators: target.characteristics.order(:position).map do |indicator|
                build_element_hash(indicator)
              end
            )
          end
        )
      end
    end

    def build_element_hash(element)
      {
        name: element.name,
        short_name: element.short_name,
        description: element.description,
        code: element.code,
        color: element.color
      }.compact.transform_values(&:strip)
    end
  end
end
