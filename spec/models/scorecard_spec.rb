require 'rails_helper'

RSpec.describe Scorecard, type: :model do
  
  let!(:characteristic) { create(:characteristic) }
  let(:scorecard) { create(:scorecard, initiatives: create_list(:initiative, 10)) }
  
  context '#merge' do
    let(:other_scorecard) { create(:scorecard, initiatives: create_list(:initiative, 5)) }
    
    subject(:merged) { scorecard.merge(other_scorecard) }
    
    it { expect(merged.name).to eq(scorecard.name) }
    
    it { expect(merged.description).to eq(scorecard.description) }
    it { expect(merged.shared_link_id).to_not be_blank }
    it { expect(merged.shared_link_id).to eq(scorecard.shared_link_id) }
    
    it { expect(merged.wicked_problem).to eq(scorecard.wicked_problem) }
    it { expect(merged.community).to eq(scorecard.community) }

    it { expect(merged.initiatives.count).to eq(scorecard.initiatives.count + other_scorecard.initiatives.count) }
    it { expect(merged.initiatives).to_not eq(scorecard.initiatives + other_scorecard.initiatives) }
    
    it 'removes all initiatives from merged scorecard' do
      merged
      other_scorecard.reload
      expect(other_scorecard.initiatives.count).to eq(0)
    end
  end
end