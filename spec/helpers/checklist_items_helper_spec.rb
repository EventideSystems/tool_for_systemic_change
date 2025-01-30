# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChecklistItemsHelper, type: :helper do
  describe '#checklist_list_item_grid_element_class' do
    let(:status) { 'actual' }
    let(:checklist_item_data) { { status:, focus_area_id: '1' } }

    context 'when grid_mode is :modern and status is "no_comment"' do
      let(:checklist_item_data) { { status: 'no_comment' } }

      it 'sets the correct class based on the status' do
        result = helper.checklist_list_item_grid_element_class(checklist_item_data:, grid_mode: :modern)
        expect(result).to eq('status-no-comment')
      end
    end

    context 'when grid_mode is :modern and status is "actual"' do
      it 'sets the correct class based on the status' do
        result = helper.checklist_list_item_grid_element_class(checklist_item_data:, grid_mode: :modern)
        expect(result).to eq('status-actual')
      end
    end

    context 'when grid_mode is :classic and status is :no_comment' do
      let(:status) { 'no_comment' }

      it 'sets the correct class based on the status' do
        result = helper.checklist_list_item_grid_element_class(checklist_item_data:, grid_mode: :classic)
        expect(result).to eq('status-no-comment')
      end
    end

    context 'when grid_mode is :classic and status is :actual' do
      it 'sets the correct class based on the focus area status color' do
        result = helper.checklist_list_item_grid_element_class(checklist_item_data:, grid_mode: :classic)
        expect(result).to eq('status-focus-area-1-actual')
      end
    end
  end
end
