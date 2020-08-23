require 'rails_helper'

RSpec.describe Reports::ScorecardComments do
  
  subject { Reports::ScorecardComments.new(scorecard, date) }
  
  include_examples 'system data examples'
  
  let(:scorecard) { create(:scorecard) }
  let(:date) { Date.parse('2016-02-11') }
  
  describe '#results' do
    
    before do
      # Data before date range 
      Timecop.freeze(date + 1.day)
  
      # Comments in the first initiative
      initiative_1.checklist_items.find_by(characteristic: characteristic_1_1).update!(comment: 'Ingored comment')
      initiative_1.checklist_items.find_by(characteristic: characteristic_1_2).update!(comment: 'Ignored comment')
      initiative_2.checklist_items.find_by(characteristic: characteristic_1_1).update!(comment: 'Ignored comment')
      initiative_2.checklist_items.find_by(characteristic: characteristic_2_1).update!(comment: 'Ignored comment')
      initiative_3 # force generation of checklist items in base (nil) checked state  
      Timecop.return
  
      # Data within date range - first change
      Timecop.freeze(date - 2.day)
      initiative_1.checklist_items.find_by(characteristic: characteristic_1_1).update!(comment: 'Initial comment')
      initiative_1.checklist_items.find_by(characteristic: characteristic_1_2).update!(comment: 'Initial comment')
      initiative_2.checklist_items.find_by(characteristic: characteristic_1_1).update!(comment: 'Initial comment')
      initiative_2.checklist_items.find_by(characteristic: characteristic_1_2).update!(comment: 'Initial comment')
      Timecop.return
    
      # Data within date range - first change
      Timecop.freeze(date - 1.day)
      initiative_1.checklist_items.find_by(characteristic: characteristic_1_1).update!(comment: 'Second comment')
      initiative_1.checklist_items.find_by(characteristic: characteristic_1_2).update!(comment: 'Second comment')
      initiative_2.checklist_items.find_by(characteristic: characteristic_1_1).update!(comment: 'Second comment')
      initiative_2.checklist_items.find_by(characteristic: characteristic_2_1).update!(comment: 'Initial comment')
      initiative_3.checklist_items.find_by(characteristic: characteristic_2_2).update!(comment: 'Initial comment')
      Timecop.return
    end
    
    let(:initiative_1) { create(:initiative, name: 'initiative_1', scorecard: scorecard)}
    let(:initiative_2) { create(:initiative, name: 'initiative_2', scorecard: scorecard)}
    let(:initiative_3) { create(:initiative, name: 'initiative_3', scorecard: scorecard)}
    
    pending "add some examples to (or delete) #{__FILE__}"    end

    it do
      # results = subject.results  
  end
end
