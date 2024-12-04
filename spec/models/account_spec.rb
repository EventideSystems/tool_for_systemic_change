# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                                                 :integer          not null, primary key
#  allow_sustainable_development_goal_alignment_cards :boolean          default(FALSE)
#  allow_transition_cards                             :boolean          default(TRUE)
#  deactivated                                        :boolean
#  deleted_at                                         :datetime
#  description                                        :string
#  expires_on                                         :date
#  expiry_warning_sent_on                             :date
#  max_scorecards                                     :integer          default(1)
#  max_users                                          :integer          default(1)
#  name                                               :string
#  sdgs_alignment_card_characteristic_model_name      :string           default("Targets")
#  sdgs_alignment_card_focus_area_group_model_name    :string           default("Focus Area Group")
#  sdgs_alignment_card_focus_area_model_name          :string           default("Focus Area")
#  sdgs_alignment_card_model_name                     :string           default("SDGs Alignment Card")
#  solution_ecosystem_maps                            :boolean
#  transition_card_characteristic_model_name          :string           default("Characteristic")
#  transition_card_focus_area_group_model_name        :string           default("Focus Area Group")
#  transition_card_focus_area_model_name              :string           default("Focus Area")
#  transition_card_model_name                         :string           default("Transition Card")
#  weblink                                            :string
#  welcome_message                                    :text
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#  stakeholder_type_id                                :integer
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'create account' do
    # rubocop:disable RSpec/IndexedLet,RSpec/LetSetup,Naming/VariableNumber
    let!(:stakeholder_type_1) { create(:stakeholder_type, name: 'StakeholderType 1', account_id: nil) }
    let!(:stakeholder_type_2) { create(:stakeholder_type, name: 'StakeholderType 2', account_id: nil) }
    # rubocop:enable RSpec/IndexedLet,RSpec/LetSetup,Naming/VariableNumber

    it 'creates stakeholder_types for the account' do # rubocop:disable RSpec/MultipleExpectations
      account = described_class.create(name: 'Test Account')

      expect(account.stakeholder_types.count).to eq(2)
      expect(StakeholderType.count).to eq(4)
      expect(account.stakeholder_types.first.name).to eq('StakeholderType 1')
      expect(account.stakeholder_types.first.id).not_to eq(stakeholder_type_1.id)
    end
  end
end
