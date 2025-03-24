# frozen_string_literal: true

module Workspaces
  class Copy # rubocop:disable Style/Documentation
    attr_reader :workspace, :new_name

    def self.call(workspace:, new_name: nil)
      new(workspace:, new_name:).call
    end

    def initialize(workspace:, new_name: nil)
      @workspace = workspace
      @new_name = new_name.presence || "#{workspace.name} (copy)"
    end

    def call
      workspace.dup.tap do |new_workspace|
        new_workspace.name = new_name
        new_workspace.save!

        # For now, remove stakeholder types and focus area groups created by the Workspace#setup_workspace method
        new_workspace.reload
        new_workspace.stakeholder_types.delete_all
        new_workspace.focus_area_groups.delete_all

        copy_stakeholder_types(new_workspace)
        copy_focus_area_groups(new_workspace)
      end
    end

    private

    def copy_stakeholder_types(new_workspace)
      workspace.stakeholder_types.each do |stakeholder_type|
        new_stakeholder_type = stakeholder_type.dup
        new_stakeholder_type.workspace = new_workspace
        new_stakeholder_type.save!
      end
    end

    def copy_focus_area_groups(new_workspace)
      FocusAreaGroup.where(workspace:).find_each do |focus_area_group|
        new_focus_area_group = create_focus_area_group(focus_area_group, new_workspace)

        focus_area_group.focus_areas.each do |focus_area|
          new_focus_area = create_focus_area(new_focus_area_group, focus_area)

          focus_area.characteristics.each do |characteristic|
            create_characteristic(new_focus_area, characteristic)
          end

          new_focus_area_group.save!
        end
      end
    end

    def create_focus_area_group(focus_area_group, new_workspace)
      FocusAreaGroup.create!(
        focus_area_group
          .attributes.except('id', 'created_at', 'updated_at')
          .merge(workspace_id: new_workspace.id)
      )
    end

    def create_focus_area(new_focus_area_group, focus_area)
      new_focus_area_group.focus_areas.build(
        focus_area.attributes.except('id', 'focus_area_group_id', 'created_at', 'updated_at')
      )
    end

    def create_characteristic(new_focus_area, characteristic)
      new_focus_area.characteristics.build(
        characteristic.attributes.except('id', 'focus_area_id', 'created_at', 'updated_at')
      )
    end
  end
end
