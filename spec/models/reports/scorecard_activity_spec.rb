require 'rails_helper'

RSpec.describe Reports::ScorecardActivity do
  
  subject { Reports::ScorecardActivity.new(scorecard, date_from, date_to) }
  
  include_examples 'system data examples'

  let(:scorecard) { create(:scorecard) }
  let(:date_from) { Date.parse('2016-02-11') }
  let(:date_to) { Date.parse('2016-03-11') }
  
  before do
  
    # Data before date range 
    Timecop.freeze(date_from - 1.day)
  
    # Check items in the first initiative
    initiative_1.checklist_items.find_by(characteristic: characteristic_1_1).update!(checked: true)
    initiative_1.checklist_items.find_by(characteristic: characteristic_1_2).update!(checked: true)
  
    # Check items in the second initiative
    initiative_2.checklist_items.find_by(characteristic: characteristic_1_1).update!(checked: true)
    initiative_2.checklist_items.find_by(characteristic: characteristic_2_1).update!(checked: true)

    initiative_3 # force generation of checklist items in base (nil) checked state
  
    Timecop.return
  
    # Data within date range
    Timecop.freeze(date_to - 1.day)
    # Check items in the first initiative
    initiative_1.checklist_items.find_by(characteristic: characteristic_2_1).update!(checked: true)
    initiative_1.checklist_items.find_by(characteristic: characteristic_2_2).update!(checked: true)
  
    # Uncheck items in the second initiative
    initiative_2.checklist_items.find_by(characteristic: characteristic_1_1).update!(checked: false)
    initiative_2.checklist_items.find_by(characteristic: characteristic_2_1).update!(checked: false)
  
    # Check items in the second initiative
    initiative_2.checklist_items.find_by(characteristic: characteristic_2_2).update!(checked: true)
  
    # Check items in the third initiative
    initiative_3.checklist_items.find_by(characteristic: characteristic_1_1).update!(checked: true)
  
    Timecop.return
  end
  
  describe '#results' do
  
    RSpec.shared_examples "a valid result" do
    
      it do
        results = subject.results

        expected = [
          focus_area_1_hash.merge({ characteristic: "characteristic_1_1", initial: 2, additions: 1, removals: 1, final: 2 }),
          focus_area_1_hash.merge({ characteristic: "characteristic_1_2", initial: 1, additions: 0, removals: 0, final: 1 }),
          focus_area_2_hash.merge({ characteristic: "characteristic_2_1", initial: 1, additions: 1, removals: 1, final: 1 }),
          focus_area_2_hash.merge({ characteristic: "characteristic_2_2", initial: 0, additions: 2, removals: 0, final: 2 })
        ]

        expect(results).to match(expected)
      end
    end
  end
  
  describe '#initiative_totals' do
    
    # Initial initiative
    let!(:initiative_1) { create(:initiative, name: 'initiative_1', scorecard: scorecard, created_at: date_from - 1.day) } 
    # Added initiatives
    let!(:initiative_2) { create(:initiative, name: 'initiative_2', scorecard: scorecard, created_at: date_from + 1.day) }
    let!(:initiative_3) { create(:initiative, name: 'initiative_3', scorecard: scorecard, created_at: date_from + 1.day) }
    # Initial initiative, then deleted
    let!(:initiative_4) { create(:initiative, name: 'initiative_3', scorecard: scorecard, created_at: date_from - 1.day, deleted_at: date_from + 1.day) }
    # Exluded intitiative
    let!(:initiative_5) { create(:initiative, name: 'initiative_3', scorecard: scorecard, created_at: date_to + 1.day) }
    
    it do
      expect(subject.initiative_totals).to match({initial: 2, additions: 2, removals: 1, final: 3})
    end
      
  end
end
