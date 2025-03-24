# frozen_string_literal: true

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
#  stakeholder_type_id :integer
#  workspace_id        :integer
#
# Indexes
#
#  index_organisations_on_deleted_at    (deleted_at)
#  index_organisations_on_workspace_id  (workspace_id)
#
require 'rails_helper'

RSpec.describe Organisation, type: :model do
  describe 'validations' do
    describe 'stakeholder_type_is_in_same_workspace' do
      let(:workspace) { create(:workspace) }
      let(:stakeholder_type) { create(:stakeholder_type, workspace: workspace) }
      let(:organisation) { build(:organisation, workspace: workspace, stakeholder_type: stakeholder_type) }

      before { organisation.valid? }

      it 'is valid' do
        expect(organisation).to be_valid
      end

      context 'when stakeholder_type is not in the same workspace' do # rubocop:disable RSpec/NestedGroups
        let(:stakeholder_type) { create(:stakeholder_type) }

        it { expect(organisation).not_to be_valid }
        it { expect(organisation.errors.full_messages).to include('Stakeholder type must be in the same workspace') }
      end
    end
  end
end
