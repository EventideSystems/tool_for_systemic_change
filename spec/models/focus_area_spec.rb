# frozen_string_literal: true

# == Schema Information
#
# Table name: focus_areas
#
#  id                  :integer          not null, primary key
#  code                :string
#  color               :string
#  deleted_at          :datetime
#  description         :string
#  icon_name           :string           default("")
#  name                :string
#  position            :integer
#  short_name          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  focus_area_group_id :integer
#
# Indexes
#
#  index_focus_areas_on_deleted_at                    (deleted_at)
#  index_focus_areas_on_focus_area_group_id           (focus_area_group_id)
#  index_focus_areas_on_focus_area_group_id_and_code  (focus_area_group_id,code) UNIQUE
#  index_focus_areas_on_position                      (position)
#
require 'rails_helper'

RSpec.describe FocusArea, type: :model do
  describe 'validations' do
    let(:impact_card_data_model) { create(:impact_card_data_model) }
    let(:focus_area_group) { create(:focus_area_group, impact_card_data_model: impact_card_data_model) }
    let!(:existing_focus_area) { create(:focus_area, focus_area_group: focus_area_group, code: 'FA1') } # rubocop:disable RSpec/LetSetup

    context 'when the code is unique within the impact card data model' do
      it 'is valid' do
        new_focus_area = build(:focus_area, focus_area_group: focus_area_group, code: 'FA2')
        expect(new_focus_area).to be_valid
      end
    end

    context 'when the code is not unique within the impact card data model' do
      it 'is not valid' do # rubocop:disable RSpec/MultipleExpectations
        new_focus_area = build(:focus_area, focus_area_group: focus_area_group, code: 'FA1')
        expect(new_focus_area).not_to be_valid
        expect(new_focus_area.errors[:code]).to include('is already taken in this data model')
      end
    end

    context 'when the code is blank' do
      it 'is valid (skips validation)' do
        new_focus_area = build(:focus_area, focus_area_group: focus_area_group, code: nil)
        expect(new_focus_area).to be_valid
      end
    end
  end
end
