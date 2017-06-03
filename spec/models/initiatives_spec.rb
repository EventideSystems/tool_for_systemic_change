require 'rails_helper'

RSpec.describe Initiative, type: :model do
  
  context '#checklist_items_ordered_by_ordered_focus_area' do
    let!(:characteristic_1) { create(:characteristic) }
    let!(:characteristic_2) { create(:characteristic) }
    let(:initiative) { create(:initiative) }
    
    it 'checklist item count equals characteristic count' do
      expect(initiative.checklist_items_ordered_by_ordered_focus_area.count).to be(2)
    end
    
    context 'with selected_date' do
      
      it 'retrieves original checklist item state if no changes have occurred' do
        checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(Date.today)
        expect(checklist_items[0].checked).to be_falsy
        expect(checklist_items[1].checked).to be_falsy
      end
      
      context 'after changes' do
        
        before do
          checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(Date.today)
          Timecop.freeze(Date.today + 10)
          checklist_items[1].update_attributes!(checked: true)
          Timecop.return
          
          Timecop.freeze(Date.today + 20)
          checklist_items[1].update_attributes!(checked: false)
          Timecop.return
        end  
          
        
        it 'retrieves previous checklist item state if selected_date is before changes have occurred' do
          checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(Date.yesterday)

          expect(checklist_items[0].checked).to be_falsy
          expect(checklist_items[1].checked).to be_falsy
        end
        
        it 'retrieves updated checklist item state if selected_date is after changes have occurred' do
          checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(Date.today + 11)

          expect(checklist_items[0].checked).to be_falsy
          expect(checklist_items[1].checked).to be_truthy
        end
        
        it 'retrieves updated checklist item state if selected_date is after changes have re-occurred' do
          checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(Date.today + 21)

          expect(checklist_items[0].checked).to be_falsy
          expect(checklist_items[1].checked).to be_falsy
        end
      end
    end
  end
end