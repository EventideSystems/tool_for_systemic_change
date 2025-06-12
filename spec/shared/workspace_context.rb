# frozen_string_literal: true

RSpec.shared_context 'with simple workspace' do
  let(:workspace) { create(:workspace) }
  let(:data_model) { create(:data_model, workspace:) }
  let(:focus_area_group) { create(:focus_area_group, data_model:) }
  let(:focus_area) { create(:focus_area, focus_area_group:, position: 1) }
  let(:characteristic) { create(:characteristic, focus_area:) }
end
