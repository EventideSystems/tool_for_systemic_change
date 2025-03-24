# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Workspaces::Copy, type: :service) do
  let(:workspace) { create(:workspace) }
  let(:new_name) { "#{workspace.name} (copy)" }

  before do
    # Create some stakeholder types and focus area groups for the workspace
    create_list(:stakeholder_type, 3, workspace:)
    create_list(:focus_area_group, 2, workspace:)
  end

  describe '.call' do
    let(:execute_call) { described_class.call(workspace:, new_name:) }

    it 'creates a new workspace with the specified name' do # rubocop:disable RSpec/MultipleExpectations
      expect { execute_call }.to(change(Workspace, :count).by(1))
      new_workspace = Workspace.last
      expect(new_workspace.name).to(eq(new_name))
    end

    it 'copies stakeholder types to the new workspace' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      execute_call
      new_workspace = Workspace.last
      expect(new_workspace.stakeholder_types.count).to(eq(workspace.stakeholder_types.count))
      new_workspace.stakeholder_types.each do |new_stakeholder_type|
        expect(workspace.stakeholder_types.pluck(:name)).to(include(new_stakeholder_type.name))
      end
    end

    it 'copies focus area groups to the new workspace' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      execute_call
      new_workspace = Workspace.last
      expect(new_workspace.focus_area_groups.count).to(eq(workspace.focus_area_groups.count))
      new_workspace.focus_area_groups.each do |new_focus_area_group|
        expect(workspace.focus_area_groups.pluck(:name)).to(include(new_focus_area_group.name))
      end
    end
  end
end
