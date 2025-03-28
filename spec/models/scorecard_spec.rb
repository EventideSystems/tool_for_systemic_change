# frozen_string_literal: true

# == Schema Information
#
# Table name: scorecards
#
#  id                         :integer          not null, primary key
#  deleted_at                 :datetime
#  deprecated_type            :string           default("TransitionCard")
#  description                :string
#  name                       :string
#  share_ecosystem_map        :boolean          default(TRUE)
#  share_thematic_network_map :boolean          default(TRUE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  community_id               :integer
#  impact_card_data_model_id  :bigint
#  linked_scorecard_id        :integer
#  shared_link_id             :string
#  wicked_problem_id          :integer
#  workspace_id               :integer
#
# Indexes
#
#  index_scorecards_on_deleted_at                 (deleted_at)
#  index_scorecards_on_deprecated_type            (deprecated_type)
#  index_scorecards_on_impact_card_data_model_id  (impact_card_data_model_id)
#  index_scorecards_on_workspace_id               (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (impact_card_data_model_id => impact_card_data_models.id)
#
require 'rails_helper'
require 'shared/workspace_context'

RSpec.describe Scorecard, type: :model do
  include_context 'with simple workspace'

  let(:scorecard) { create(:scorecard, impact_card_data_model:, workspace:) }

  before { create_list(:initiative, 10, scorecard:) }

  describe '#merge' do
    subject(:merged) { scorecard.merge(other_scorecard) }

    let(:other_scorecard) do
      create(:scorecard, impact_card_data_model:, workspace:)
    end

    before { create_list(:initiative, 10, scorecard: other_scorecard) }

    it { expect(merged.name).to eq(scorecard.name) }

    it { expect(merged.description).to eq(scorecard.description) }
    it { expect(merged.shared_link_id).not_to be_blank }
    it { expect(merged.shared_link_id).to eq(scorecard.shared_link_id) }

    it { expect(merged.wicked_problem).to eq(scorecard.wicked_problem) }
    it { expect(merged.community).to eq(scorecard.community) }

    it { expect(merged.initiatives.count).to eq(scorecard.initiatives.count + other_scorecard.initiatives.count) }
    it { expect(merged.initiatives).not_to eq(scorecard.initiatives + other_scorecard.initiatives) }

    it 'removes all initiatives from merged scorecard' do
      merged
      other_scorecard.reload
      expect(other_scorecard.initiatives.count).to eq(0)
    end
  end
end
