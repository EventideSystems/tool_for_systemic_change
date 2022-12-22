require 'rails_helper'

RSpec.describe Account, type: :model do

  describe 'create account' do
    let!(:stakeholder_type_1) { create(:stakeholder_type, name: 'StakeholderType 1', account_id: nil) }
    let!(:stakeholder_type_2) { create(:stakeholder_type, name: 'StakeholderType 2', account_id: nil) }

    it 'should create stakeholder_types for the account' do
      account = Account.create(name: 'Test Account')

      expect(account.stakeholder_types.count).to eq(2)
      expect(StakeholderType.count).to eq(4)
      expect(account.stakeholder_types.first.name).to eq('StakeholderType 1')
      expect(account.stakeholder_types.first.id).to_not eq(stakeholder_type_1.id)
    end
  end
end
