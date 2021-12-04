require 'rails_helper'

RSpec.describe Events::TransitionCardActivity, type: :model do
  context 'when checking a ChecklistItem for the first time' do
    let!(:characteristic) { create(:characteristic, name: 'dummy') }
    let(:initiative) { create(:initiative, name: 'dummy') }
    let!(:checklist_item) { initiative.checklist_items.first }

    it 'should create a new TransitionCardActivity' do
      expect { checklist_item.update!(checked: true) }.to change { TransitionCardActivity.count }.by(1)
    end
  end
end
