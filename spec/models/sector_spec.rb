require 'rails_helper'

RSpec.describe Sector, type: :model do

  specify 'Sectors have polymorphic association with Organisations' do
    sector = create(:sector)

    create(:organisation, sector: sector)
    create(:client, sector: sector)

    expect(sector.organisations.count).to be(1)
    expect(sector.clients.count).to be(1)
    expect(sector.organisations[0].class.name).to eq('Organisation')
    expect(sector.clients[0].class.name).to eq('Client')
  end
end
