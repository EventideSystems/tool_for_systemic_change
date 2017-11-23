require 'rails_helper'

RSpec.describe ScorecardCopier do
  let!(:characteristic) { create(:characteristic) }
  let!(:scorecard) { create(:scorecard, initiatives: create_list(:initiative, 2) ) }
  
  subject(:copied) { ScorecardCopier.new(scorecard, 'new name', deep_copy: deep_copy?).perform }
  
  context '#copied' do
    
    let(:deep_copy?) { false }
    let(:copied_first_initiative) { copied.initiative.where(name: scorecard.initiatives.first.name)}
    
    before do 
      scorecard.initiatives.first.organisations = create_list(:organisation, 5)
      scorecard.initiatives.first.save
    end 
    
    it { expect(copied.name).to eq('new name') }
    
    it { expect(copied.description).to eq(scorecard.description) }
    it { expect(copied.shared_link_id).to_not be_blank }
    it { expect(copied.shared_link_id).to_not eq(scorecard.shared_link_id) }
    
    it { expect(copied.wicked_problem).to eq(scorecard.wicked_problem) }
    it { expect(copied.community).to eq(scorecard.community) }

    it { expect(copied.initiatives.count).to eq(scorecard.initiatives.count) }
    it { expect(copied.initiatives).to_not eq(scorecard.initiatives) }
    
    it do
      copied_first_initiative.reload
      expect(copied_first_initiative.organisations.count).to eq(5) 
    end
  end
  
  context '#deep_copied', :run_delayed_jobs do

    let(:deep_copy?) { true }
    
    it { expect(copied.name).to eq('new name') }
    it { expect(copied.description).to eq(scorecard.description) }
    it { expect(copied.shared_link_id).to_not be_blank }
    it { expect(copied.shared_link_id).to_not eq(scorecard.shared_link_id) }
    
    it { expect(copied.wicked_problem).to eq(scorecard.wicked_problem) }
    it { expect(copied.community).to eq(scorecard.community) }

    it { expect(copied.initiatives.count).to eq(scorecard.initiatives.count) }
    it { expect(copied.initiatives).to_not eq(scorecard.initiatives) }

    context 'initiatives' do
      let(:scorcard_first_initiative) { scorecard.initiatives.first }
      let(:scorcard_first_checklist_item) { scorcard_first_initiative.checklist_items.first }

      before do
        scorcard_first_checklist_item.checked = true
        scorcard_first_checklist_item.comment = 'Comment'
        scorcard_first_checklist_item.save!
      end

      it do
        copied.initiatives.reload
        copied_first_initiative = copied.initiatives.first 
        copied_first_checklist_item = copied_first_initiative.checklist_items.first
        expect(copied_first_checklist_item.comment).to eq('Comment') 
      end
    end
    
    context 'history' do
      before do 
        scorecard.update_attributes(name: 'Updated Name')
      end

      context 'paper trail' do
        let(:original_scorecard_versions) {
          PaperTrail::Version.where(
            item_type: "Scorecard",
            item_id: scorecard.id
          )
        }

        let(:copied_scorecard_versions) {
          PaperTrail::Version.where(
            item_type: "Scorecard",
            item_id: subject.id
          )
        }

        it { expect(original_scorecard_versions.count).to be(2) }

        it { expect(copied_scorecard_versions.count).to be(2) }
        
        it 'MUST copied all scorecard attributes (other than id and trackable_id)' do
          copied_scorecard_versions.each_with_index do |copied_scorecard_activity, index|
            original_attributes = original_scorecard_versions[index].attributes.delete([:id, :trackable_id])
            copied_attributes = copied_scorecard_activity.attributes.delete([:id, :trackable_id])

            expect(copied_attributes).to match(original_attributes)
          end
        end
      end
    end
  end
end