require 'rails_helper'

RSpec.describe Organisation, type: :model do


  describe 'validations' do

    describe 'stakeholder_type_is_in_same_account' do
      let(:account) { create(:account) }
      let(:stakeholder_type) { create(:stakeholder_type, account: account) }
      let(:organisation) { build(:organisation, account: account, stakeholder_type: stakeholder_type) }

      it 'should be valid' do
        expect(organisation).to be_valid
      end

      context 'when stakeholder_type is not in the same account' do
        let(:stakeholder_type) { create(:stakeholder_type) }

        it 'should be invalid' do
          expect(organisation).to_not be_valid
          expect(organisation.errors.full_messages).to include('Stakeholder type must be in the same account')
        end
      end
    end
  end
end
