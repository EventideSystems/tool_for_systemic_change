# frozen_string_literal: true

RSpec.shared_context('system data examples') do
  # rubocop:disable Naming/VariableNumber
  let!(:focus_area_group) { create(:focus_area_group, name: 'focus_area_group') }
  let!(:focus_area_1) { create(:focus_area, name: 'focus_area_1', focus_area_group:) }
  let!(:focus_area_2) { create(:focus_area, name: 'focus_area_2', focus_area_group:) }

  let(:focus_area_1_hash) { { focus_area_group: 'focus_area_group', focus_area: 'focus_area_1' } }
  let(:focus_area_2_hash) { { focus_area_group: 'focus_area_group', focus_area: 'focus_area_2' } }

  let!(:characteristic_1_1) { create(:characteristic, name: 'characteristic_1_1', focus_area: focus_area_1) }
  let!(:characteristic_1_2) { create(:characteristic, name: 'characteristic_1_2', focus_area: focus_area_1) }
  let!(:characteristic_2_1) { create(:characteristic, name: 'characteristic_2_1', focus_area: focus_area_2) }
  let!(:characteristic_2_2) { create(:characteristic, name: 'characteristic_2_2', focus_area: focus_area_2) }
  # rubocop:enable Naming/VariableNumber
end
