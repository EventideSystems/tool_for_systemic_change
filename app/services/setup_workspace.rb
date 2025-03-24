# frozen_string_literal: true

# Set up new workspace with default data
class SetupWorkspace
  attr_reader :workspace

  def self.call(workspace:)
    new(workspace:).call
  end

  def initialize(workspace:)
    @workspace = workspace
  end

  def call
    create_stakeholder_types
    create_focus_area_groups
  end

  private

  def create_stakeholder_types
    StakeholderType.system_stakeholder_types.each do |template|
      template
        .dup
        .tap { |s| s.workspace = workspace }
        .save!
    end
  end

  def create_focus_area_groups # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    FocusAreaGroup.where(workspace: nil).find_each do |focus_area_group|
      new_focus_area_group = \
        FocusAreaGroup
        .create(
          focus_area_group
            .attributes.except('id', 'created_at', 'updated_at')
            .merge('workspace_id' => workspace.id)
        )

      focus_area_group.focus_areas.each do |focus_area|
        new_focus_area = \
          new_focus_area_group
          .focus_areas
          .build(focus_area.attributes.except('id', 'focus_area_group_id', 'created_at', 'updated_at'))

        focus_area.characteristics.each do |characteristic|
          new_focus_area
            .characteristics
            .build(characteristic.attributes.except('id', 'focus_area_id', 'created_at', 'updated_at'))
        end

        new_focus_area_group.save!
      end
    end
  end
end
