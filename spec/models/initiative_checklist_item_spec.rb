require 'rails_helper'

RSpec.describe InitiativeChecklistItem, type: :model do

  let(:initiative) {
    initiative = build(:initiative)
    initiative.save!

    initiative.reload
    initiative
  }

  specify "auto-created items have associated initiatives" do
    expect(initiative.checklist_items.first.initiative).to eq(initiative)
  end

  specify "auto-created items have associated initiative characteristic" do
    expect(Model::InitiativeCharacteristic.first).to_not be_nil
    expect(initiative.checklist_items.first.initiative_characteristic)
      .to eq(Model::InitiativeCharacteristic.first)
  end
end
