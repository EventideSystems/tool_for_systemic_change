require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Checklist Items", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"
  include_context "setup model data"

  let!(:initiative) { create(:initiative, scorecard: scorecard, organisations: [organisation]) }

  describe "GET /initiatives/:initiative_id/checklist_items" do

    specify 'all fields returned' do
      sign_in(staff)
      get initiative_checklist_items_path(initiative)

      checklist_data = JSON.parse(response.body)['data'].first

      relationships_data = checklist_data['relationships']

      expect(relationships_data['characteristic']['data']['id']).to_not be(nil)
      expect(relationships_data['initiative']['data']['id']).to_not be(nil)

      included_data = JSON.parse(response.body)['included']

      focus_areas = included_data.select do |included|
        included['type'] == 'focus_areas'
      end

      expect(focus_areas.count).to eq(FocusArea.count)

      focus_area_groups = included_data.select do |included|
        included['type'] == 'focus_area_groups'
      end

      expect(focus_area_groups.count).to eq(FocusAreaGroup.count)

      characteristics = included_data.select do |included|
        included['type'] == 'characteristics'
      end

      expect(characteristics.count).to eq(Characteristic.count)
    end

    specify 'record count matches number of initiative characteristics' do
      sign_in(staff)
      get initiative_checklist_items_path(initiative)

      checklist_data = JSON.parse(response.body)['data']
      expect(checklist_data.count).to eq(Characteristic.count)
    end

  end

  describe "PUT /initiatives/:id/checklist_items/:id" do

    specify "update single checklist item" do
      data_attributes = {
        type: 'checklist_items',
        attributes: {
          checked: true,
          comment: FFaker::Lorem.words.join(' ')
        }
      }

      sign_in(staff)
      checklist_item = initiative.checklist_items.first
      put initiative_checklist_item_path(initiative, checklist_item), data: data_attributes
      expect(response).to have_http_status(200)

      checklist_item.reload

      expect(checklist_item.checked).to be(true)
      expect(checklist_item.comment).to eq(data_attributes[:attributes][:comment])
    end
  end

  describe "PUT /initiatives/:id/checklist_items" do

    specify "bulk update" do
      checklist_item_1 = initiative.checklist_items.first
      checklist_item_2 = initiative.checklist_items.second

      data_attributes = [
        { id: checklist_item_1.id,
          type: 'checklist_items',
          attributes: {
            checked: true,
            comment: FFaker::Lorem.words.join(' ')
          }
        },
        { id: checklist_item_2.id,
          type: 'checklist_items',
          attributes: {
            checked: true,
            comment: FFaker::Lorem.words.join(' ')
          }
        }
      ]

      sign_in(staff)
      put "/initiatives/#{initiative.id}/checklist_items", data: data_attributes

      checklist_item_1.reload
      checklist_item_2.reload

      expect(checklist_item_1.checked).to be(true)
      expect(checklist_item_1.comment).to eq(data_attributes.first[:attributes][:comment])
      expect(checklist_item_1.checked).to be(true)
      expect(checklist_item_1.comment).to eq(data_attributes.first[:attributes][:comment])
    end
  end
end
