require 'rails_helper'

RSpec.describe EcosystemMaps::Organisations do
  let!(:transition_card) { create(:scorecard, initiatives: create_list(:initiative, 2) ) }
  let!(:organisation_1) { create(:organisation) }
  let!(:organisation_2) { create(:organisation) }

  let(:service) { described_class.new(transition_card) }

  describe 'nodes' do
    before do
      InitiativesOrganisation.create!(
        organisation: organisation_1,
        initiative: transition_card.initiatives.first
      )

      InitiativesOrganisation.create!(
        organisation: organisation_2,
        initiative: transition_card.initiatives.first
      )
    end

    it { expect(service.nodes.count).to eq(2) }
  end
end
