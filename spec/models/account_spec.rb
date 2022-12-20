require 'rails_helper'

RSpec.describe Account, type: :model do

  describe 'create account' do
    let!(:sector_1) { create(:sector, name: 'Sector 1', account_id: nil) }
    let!(:sector_2) { create(:sector, name: 'Sector 2', account_id: nil) }

    it 'should create sectors for the account' do
      account = Account.create(name: 'Test Account')

      expect(account.sectors.count).to eq(2)
      expect(Sector.count).to eq(4)
      expect(account.sectors.first.name).to eq('Sector 1')
      expect(account.sectors.first.id).to_not eq(sector_1.id)
    end
  end
end
