require 'rails_helper'

RSpec.describe ChecklistItem, type: :model do

  let(:initiative) {
    initiative = build(:initiative)
    initiative.save!

    initiative.reload
    initiative
  }

  specify "auto-created items have associated initiatives" do
    expect(initiative.checklist_items.first.initiative).to eq(initiative)
  end

  specify "auto-created items have associated characteristic" do
    expect(Characteristic.first).to_not be_nil
    expect(initiative.checklist_items.first.characteristic)
      .to eq(Characteristic.first)
  end
end
