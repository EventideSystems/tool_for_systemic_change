require 'rails_helper'

RSpec.describe Initiative, type: :model do
  
  context '#checklist_items_ordered_by_ordered_focus_area' do
    let(:default_account) { create(:account) }
    let!(:characteristic_1) { create(:characteristic) }
    let!(:characteristic_2) { create(:characteristic) }

    let!(:initiative) { create(:initiative, organisations: create_list(:organisation, 2, account: default_account)) }
    
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
    
    context '#copy' do
      subject { initiative.copy }
      
      it { expect(subject.name).to             eq(initiative.name) }
      it { expect(subject.description).to      eq(initiative.description) }
      it { expect(subject.scorecard_id).to     eq(initiative.scorecard_id) }
      it { expect(subject.started_at).to       eq(initiative.started_at) }
      it { expect(subject.finished_at).to      eq(initiative.finished_at) }
      it { expect(subject.dates_confirmed).to  eq(initiative.dates_confirmed) }
      it { expect(subject.contact_name).to     eq(initiative.contact_name) }
      it { expect(subject.contact_email).to    eq(initiative.contact_email) }
      it { expect(subject.contact_phone).to    eq(initiative.contact_phone) }
      it { expect(subject.contact_website).to  eq(initiative.contact_website) }
      it { expect(subject.contact_position).to eq(initiative.contact_position) }
      
      context 'organisations' do
         it { expect(subject.organisations.count).to eq(2) }
      end
      
      context 'checklist items' do
        
        before do
          initiative.checklist_items.first.checked = true
          initiative.checklist_items.first.comment = 'Comment'
          initiative.checklist_items.first.save!
        end
        
        it { expect(subject.checklist_items.count).to eq(2) }
        it { expect(subject.checklist_items.count).to eq(initiative.checklist_items.count) }
        it { expect(subject.checklist_items.first.checked).to eq(nil) }
        it { expect(subject.checklist_items.first.comment).to eq(nil) }
      end
    end
    
    context '#deep_copy' do
      subject { initiative.deep_copy }
      
      it { expect(subject.name).to             eq(initiative.name) }
      it { expect(subject.description).to      eq(initiative.description) }
      it { expect(subject.scorecard_id).to     eq(initiative.scorecard_id) }
      it { expect(subject.started_at).to       eq(initiative.started_at) }
      it { expect(subject.finished_at).to      eq(initiative.finished_at) }
      it { expect(subject.dates_confirmed).to  eq(initiative.dates_confirmed) }
      it { expect(subject.contact_name).to     eq(initiative.contact_name) }
      it { expect(subject.contact_email).to    eq(initiative.contact_email) }
      it { expect(subject.contact_phone).to    eq(initiative.contact_phone) }
      it { expect(subject.contact_website).to  eq(initiative.contact_website) }
      it { expect(subject.contact_position).to eq(initiative.contact_position) }
      
      context 'organisations' do
         it { expect(subject.organisations.count).to eq(2) }
      end
      
      context 'checklist items' do
        
        before do
          initiative.checklist_items.first.checked = true
          initiative.checklist_items.first.comment = 'Comment'
          initiative.checklist_items.first.save!
        end
        
        it { expect(subject.checklist_items.count).to eq(2) }
        it { expect(subject.checklist_items.count).to eq(initiative.checklist_items.count) }
        it { expect(subject.checklist_items.first.checked).to eq(true) }
        it { expect(subject.checklist_items.first.comment).to eq('Comment') }
      end
      
      context 'history' do
        
        before do 
          initiative.update_attributes(name: 'Updated Name')
        
          initiative.checklist_items.first.checked = true
          initiative.checklist_items.first.comment = 'Comment'
          initiative.checklist_items.first.save!
        
          initiative.checklist_items.second.checked = true
          initiative.checklist_items.second.comment = 'Comment'
          initiative.checklist_items.second.save!
        end 
        
        context 'paper trail' do
        
          let(:original_initiative_versions) { 
            PaperTrail::Version.where(
              item_type: "Initiative", 
              item_id: initiative.id
            ) 
          }
      
          let(:original_checklist_item_versions) { 
            PaperTrail::Version.where(
              item_type: "ChecklistItem", 
              item_id: initiative.checklist_items.map(&:id)
            ) 
          }
      
          let(:copied_initiative_versions) { 
            PaperTrail::Version.where(
              item_type: "Initiative", 
              item_id: subject.id
            ) 
          }
      
          let(:copied_checklist_item_versions) { 
            PaperTrail::Version.where(
              item_type: "ChecklistItem", 
              item_id: subject.checklist_items.map(&:id)
            ) 
          }
          
          it { expect(original_initiative_versions.count).to be(2) }
          it { expect(original_checklist_item_versions.count).to be(4) }
        
          it { expect(copied_initiative_versions.count).to be(2) }
          it { expect(copied_checklist_item_versions.count).to be(4) }
          
          it 'MUST copy all intitiative attributes (other than id and trackable_id)' do
            copied_initiative_versions.each_with_index do |copied_initiative_activity, index|
              original_attributes = original_initiative_versions[index].attributes.delete([:id, :trackable_id])
              copied_attributes = copied_initiative_activity.attributes.delete([:id, :trackable_id])

              expect(copied_attributes).to match(original_attributes)
            end
          end

          it 'MUST copy all checklist attributes (other than id and trackable_id)' do
            copied_checklist_item_versions.each_with_index do |copied_checklist_item_activity, index|
              original_attributes = original_checklist_item_versions[index].attributes.delete([:id, :trackable_id])
              copied_attributes = copied_checklist_item_activity.attributes.delete([:id, :trackable_id])

              expect(copied_attributes).to match(original_attributes)
            end
          end
        end
      end
    end
  end
end


