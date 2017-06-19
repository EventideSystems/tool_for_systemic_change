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
    initiative_1.checklist_items.find_by(characteristic: characteristic_1_1).update_attributes!(checked: true)
    initiative_1.checklist_items.find_by(characteristic: characteristic_1_2).update_attributes!(checked: true)
  
    # Check items in the second initiative
    initiative_2.checklist_items.find_by(characteristic: characteristic_1_1).update_attributes!(checked: true)
    initiative_2.checklist_items.find_by(characteristic: characteristic_2_1).update_attributes!(checked: true)

    initiative_3 # force generation of checklist items in base (nil) checked state
  
    Timecop.return
  
    # Data within date range
    Timecop.freeze(date_to - 1.day)
    # Check items in the first initiative
    initiative_1.checklist_items.find_by(characteristic: characteristic_2_1).update_attributes!(checked: true)
    initiative_1.checklist_items.find_by(characteristic: characteristic_2_2).update_attributes!(checked: true)
  
    # Uncheck items in the second initiative
    initiative_2.checklist_items.find_by(characteristic: characteristic_1_1).update_attributes!(checked: false)
    initiative_2.checklist_items.find_by(characteristic: characteristic_2_1).update_attributes!(checked: false)
  
    # Check items in the second initiative
    initiative_2.checklist_items.find_by(characteristic: characteristic_2_2).update_attributes!(checked: true)
  
    # Check items in the third initiative
    initiative_3.checklist_items.find_by(characteristic: characteristic_1_1).update_attributes!(checked: true)
  
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
  
    context 'initiatives without date ranges' do
    
      let(:initiative_1) { create(:initiative, name: 'initiative_1', scorecard: scorecard)}
      let(:initiative_2) { create(:initiative, name: 'initiative_2', scorecard: scorecard)}
      let(:initiative_3) { create(:initiative, name: 'initiative_3', scorecard: scorecard)}

      it_behaves_like 'a valid result'
    end
  
    context 'initiatives when :started_at before date_from & :finished_at after date_to' do
    
      let(:initiative_1) { create(:initiative, name: 'initiative_1', scorecard: scorecard, started_at: date_from - 10.days)}
      let(:initiative_2) { create(:initiative, name: 'initiative_2', scorecard: scorecard, finished_at: date_to + 10.days)}
      let(:initiative_3) { create(:initiative, name: 'initiative_3', scorecard: scorecard, started_at: date_from - 10.days, finished_at: date_to + 10.days)}

      it_behaves_like 'a valid result'
    end
  
    context 'initiatives when :started_at & :finished_at within date_from & date_to' do
    
      let(:initiative_1) { create(:initiative, name: 'initiative_1', scorecard: scorecard, started_at: date_from + 1.days)}
      let(:initiative_2) { create(:initiative, name: 'initiative_2', scorecard: scorecard, finished_at: date_to - 1.days)}
      let(:initiative_3) { create(:initiative, name: 'initiative_3', scorecard: scorecard, started_at: date_from + 1.days, finished_at: date_to - 1.days)}

      it_behaves_like 'a valid result'
    end
  
    context 'initiatives when :started_at is before date_to' do
    
      let(:initiative_1) { create(:initiative, name: 'initiative_1', scorecard: scorecard, started_at: date_to - 10.days)}
      let(:initiative_2) { create(:initiative, name: 'initiative_2', scorecard: scorecard, started_at: date_to - 10.days)}
      let(:initiative_3) { create(:initiative, name: 'initiative_3', scorecard: scorecard, started_at: date_to - 10.days)}

      it_behaves_like 'a valid result'
    end
  
    context 'initiatives when :started_at & :finished_at before date_from & date_to' do
    
      let(:initiative_1) { create(:initiative, name: 'initiative_1', scorecard: scorecard, started_at: date_to - 100.days, finished_at: date_to - 50.days)}
      let(:initiative_2) { create(:initiative, name: 'initiative_2', scorecard: scorecard, started_at: date_to - 100.days, finished_at: date_to - 50.days)}
      let(:initiative_3) { create(:initiative, name: 'initiative_3', scorecard: scorecard, started_at: date_to - 100.days, finished_at: date_to - 50.days)}

      it 'returns empty results' do
        results = subject.results

        expected = [
          focus_area_1_hash.merge({ characteristic: "characteristic_1_1", initial: 0, additions: 0, removals: 0, final: 0 }),
          focus_area_1_hash.merge({ characteristic: "characteristic_1_2", initial: 0, additions: 0, removals: 0, final: 0 }),
          focus_area_2_hash.merge({ characteristic: "characteristic_2_1", initial: 0, additions: 0, removals: 0, final: 0 }),
          focus_area_2_hash.merge({ characteristic: "characteristic_2_2", initial: 0, additions: 0, removals: 0, final: 0 })
        ]

        expect(results).to match(expected)
      end
    end
  end
  
  describe '#initiative_totals' do
    
    let(:initiative_1) { create(:initiative, name: 'initiative_1', scorecard: scorecard)}
    let(:initiative_2) { create(:initiative, name: 'initiative_2', scorecard: scorecard)}
    let(:initiative_3) { create(:initiative, name: 'initiative_3', scorecard: scorecard)}
    
    it do
      expect(subject.initiative_totals).to match({initial: 2, additions: 1, removals: 1, final: 2})
    end
      
  end
end