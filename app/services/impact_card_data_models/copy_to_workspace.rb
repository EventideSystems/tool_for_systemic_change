# frozen_string_literal: true

module ImpactCardDataModels
  # Copy data model into a workspace
  class CopyToWorkspace
    attr_reader :data_model, :workspace

    def initialize(data_model:, workspace:)
      @data_model = data_model
      @workspace = workspace
    end

    def call # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      ActiveRecord::Base.transaction do
        data_model.dup.tap do |new_data_model|
          new_data_model.workspace = workspace
          new_data_model.system_model = false
          new_data_model.name = new_workspace_name
          new_data_model.save!

          data_model.focus_area_groups.each do |focus_area_group|
            new_focus_area_group = focus_area_group.dup
            new_focus_area_group.impact_card_data_model = new_data_model
            new_focus_area_group.save!

            focus_area_group.focus_areas.each do |focus_area|
              new_focus_area = focus_area.dup
              new_focus_area.focus_area_group = new_focus_area_group
              new_focus_area.save!

              focus_area.characteristics.each do |characteristic|
                new_characteristic = characteristic.dup
                new_characteristic.focus_area = new_focus_area
                new_characteristic.save!
              end
            end
          end
        end
      end
    end

    def self.call(data_model:, workspace:)
      new(data_model:, workspace:).call
    end

    private

    # Naive algorithm for finding a name for the new workspace
    def new_workspace_name
      candidate_name = data_model.name
      count = 0

      while workspace.impact_card_data_models.exists?(name: candidate_name)
        count += 1
        candidate_name = "#{data_model.name} (#{count})"
      end

      candidate_name
    end
  end
end
