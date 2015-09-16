require 'rails_helper'

RSpec.describe Initiative, type: :model do
  describe "building checklist" do
    specify "creating initiative triggers creating checklist items" do
      initiative = build(:initiative)
      initiative.save!

      initiative.reload

      expect(initiative.checklist_items.count).to eq(Characteristic.count)
    end
  end
end
