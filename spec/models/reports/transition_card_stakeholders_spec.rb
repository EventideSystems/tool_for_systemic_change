require 'rails_helper'

RSpec.describe Reports::TransitionCardStakeholders do
  subject { Reports::TransitionCardStakeholders.new(scorecard) }
  let(:scorecard) { create(:scorecard) }
  
  describe 'header section' do
    
    it '' do 
      puts subject.results
    end
  
    # Transition Card  Family Violence in Buller
    # Wicked problem / opportunity  Domesitic Violence
    # Community  Buller
    # Date generated  1/10/17
    
  end
  
end