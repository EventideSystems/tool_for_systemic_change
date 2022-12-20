require 'rails_helper'

RSpec.describe Organisation, type: :model do


  describe 'validations' do

    describe 'sector_is_in_same_account' do
      let(:account) { create(:account) }
      let(:sector) { create(:sector, account: account) }
      let(:organisation) { build(:organisation, account: account, sector: sector) }

      it 'should be valid' do
        expect(organisation).to be_valid
      end

      context 'when sector is not in the same account' do
        let(:sector) { create(:sector) }

        it 'should be invalid' do
          expect(organisation).to_not be_valid
          expect(organisation.errors.full_messages).to include('Sector must be in the same account')
        end
      end
    end
  end
end
