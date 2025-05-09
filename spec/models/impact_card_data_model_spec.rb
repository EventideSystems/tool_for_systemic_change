# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Layout/LineLength
# == Schema Information
#
# Table name: data_models
#
#  id           :bigint           not null, primary key
#  author       :string
#  color        :string           default("#0d9488"), not null
#  deleted_at   :datetime
#  description  :string
#  license      :string
#  metadata     :jsonb
#  name         :string           not null
#  short_name   :string
#  status       :string           default("active"), not null
#  public_model :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  workspace_id :bigint
#
# Indexes
#
#  index_data_models_on_name_and_workspace_id  (name,workspace_id) UNIQUE WHERE ((workspace_id IS NOT NULL) AND (deleted_at IS NULL))
#  index_data_models_on_workspace_id           (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_id => workspaces.id)
#
# rubocop:enable Layout/LineLength

RSpec.describe DataModel, type: :model do
  describe '#codes' do
    let(:data_model) { create(:data_model) }
    let(:focus_area_group) { create(:focus_area_group, data_model: data_model, code: 'FAG1') }
    let(:focus_area) { create(:focus_area, focus_area_group: focus_area_group, code: 'FA1') }
    let!(:characteristic) { create(:characteristic, focus_area: focus_area, code: 'C1') } # rubocop:disable RSpec/LetSetup

    it 'returns all codes from focus_area_groups, focus_areas, and characteristics' do
      expect(data_model.codes).to contain_exactly('FAG1', 'FA1', 'C1')
    end

    it 'returns an empty array if there are no codes' do
      empty_model = create(:data_model)
      expect(empty_model.codes).to eq([])
    end
  end
end
