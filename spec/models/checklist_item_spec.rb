require 'rails_helper'

RSpec.describe ChecklistItem, type: :model do
  let!(:characteristic) { create(:characteristic) }
  let(:initiative) { create(:initiative) }
  subject{ initiative.checklist_items.first }
  
  describe '#snapshot_at' do
    context 'without changes' do
      it { expect(subject.snapshot_at(DateTime.now)).to eq(subject) }
    end
    
    context 'with changes' do
      before do
        Timecop.freeze(Date.today + 10.days)
        subject.update_attributes(checked: true)
        Timecop.return
                
        Timecop.freeze(Date.today + 20.days)
        subject.update_attributes(checked: false)
        Timecop.return
      end
      
      it 'expects original checked state to be nil' do
        expect(subject.snapshot_at(DateTime.now).checked).to be(nil)
      end
      
      it 'expects first checked state to be true' do
        expect(subject.snapshot_at(Date.today + 11).checked).to be(true)
      end
      it 'expects first checked state to be true' do
        expect(subject.snapshot_at(Date.today + 21).checked).to be(false)
      end
    end
    
    
  end
  
end
