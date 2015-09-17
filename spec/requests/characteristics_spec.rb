require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Characteristic", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"
  include_context "setup model data"

  describe "GET /characteristics" do

    specify 'all fields returned' do
      sign_in(staff)
      get characteristics_path

      characteristic = Characteristic.first
      characteristic_data = JSON.parse(response.body)['data'].first

      expect(characteristic_data['id']).to eq(characteristic.id.to_s)
      expect(characteristic_data['attributes']['name']).to eq(characteristic.name)
      expect(characteristic_data['attributes']['description']).to eq(characteristic.description)

      relationships_data = characteristic_data['relationships']

      expect(relationships_data['focusArea']['data']['id'])
        .to eq(characteristic.focus_area.id.to_s)

      included_data = JSON.parse(response.body)['included']

      # SMELL Partial dupe from checklist_items_spec
      focus_areas = included_data.select do |included|
        included['type'] == 'focus_areas'
      end

      expect(focus_areas.count).to eq(FocusArea.count)

      focus_area_groups = included_data.select do |included|
        included['type'] == 'focus_area_groups'
      end

      expect(focus_area_groups.count).to eq(FocusAreaGroup.count)
    end
  end

  describe "GET /characteristics/:id" do

    specify 'all fields returned' do
      characteristic = Characteristic.first

      sign_in(staff)
      get characteristic_path(characteristic)

      characteristic_data = JSON.parse(response.body)['data']

      expect(characteristic_data['id']).to eq(characteristic.id.to_s)
      expect(characteristic_data['attributes']['name']).to eq(characteristic.name)
      expect(characteristic_data['attributes']['description']).to eq(characteristic.description)
    end
  end
end
