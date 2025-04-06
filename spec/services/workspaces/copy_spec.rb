# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Workspaces::Copy, type: :service) do
  let(:workspace) { create(:workspace) }
  let(:new_name) { "#{workspace.name} (copy)" }
  let(:impact_card_data_model) { create(:impact_card_data_model, workspace:) }

  before do
    # Create some stakeholder types and focus area groups for the workspace
    create_list(:stakeholder_type, 3, workspace:)
    create_list(:focus_area_group, 2, impact_card_data_model:)
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

    it 'copies impact card data models to the new workspace' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      execute_call
      new_workspace = Workspace.last
      expect(new_workspace.impact_card_data_models.count).to(eq(workspace.impact_card_data_models.count))
      new_workspace.impact_card_data_models.each do |new_impact_card_data_model|
        expect(workspace.impact_card_data_models.pluck(:name)).to(include(new_impact_card_data_model.name))
      end
    end
  end
end
