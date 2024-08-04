# == Schema Information
#
# Table name: organisations
#
#  id                  :integer          not null, primary key
#  deleted_at          :datetime
#  description         :string
#  name                :string
#  weblink             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :integer
#  stakeholder_type_id :integer
#
# Indexes
#
#  index_organisations_on_account_id  (account_id)
#  index_organisations_on_deleted_at  (deleted_at)
#
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
