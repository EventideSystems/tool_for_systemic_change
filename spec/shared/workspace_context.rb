# frozen_string_literal: true

RSpec.shared_context 'with simple workspace' do
  let(:workspace) { create(:workspace) }
  let(:impact_card_data_model) { create(:impact_card_data_model, workspace:) }
  let(:focus_area_group) { create(:focus_area_group, impact_card_data_model:) }
  let(:focus_area) { create(:focus_area, focus_area_group:, position: 1) }
  let(:characteristic) { create(:characteristic, focus_area:) }
end
