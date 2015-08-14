require 'rails_helper'

RSpec.describe Sector, type: :model do

  specify 'Sectors have polymorphic association with Organisations' do
    sector = create(:sector)
    create(:organisation, sector: sector)
    create(:administrating_organisation, sector: sector)

    expect(sector.organisations.count).to be(2)
    expect(sector.organisations[0].class.name).to eq('Organisation')
    expect(sector.organisations[1].class.name).to eq('AdministratingOrganisation')
  end
end
