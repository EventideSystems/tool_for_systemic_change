require 'rails_helper'
require 'shared_contexts'

RSpec.describe "FocusAreaGroup", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"
  include_context "setup model data"

  describe "GET /focus_area_groups" do

    specify 'all fields returned' do
      sign_in(staff)
      get focus_area_groups_path

      focus_area_group = FocusAreaGroup.first
      focus_area_group_data = JSON.parse(response.body)['data'].first

      expect(focus_area_group_data['id']).to eq(focus_area_group.id.to_s)
      expect(focus_area_group_data['attributes']['name']).to eq(focus_area_group.name)
      expect(focus_area_group_data['attributes']['description']).to eq(focus_area_group.description)

      relationships_data = focus_area_group_data['relationships']

      expect(relationships_data['focusAreas']['data'].count)
        .to be(focus_area_group.focus_areas.count)

      # SMELL Partial dupe from checklist_items_spec
      included_data = JSON.parse(response.body)['included']

      focus_areas = included_data.select do |included|
        included['type'] == 'focus_areas'
      end

      expect(focus_areas.count).to eq(FocusArea.count)

      characteristics = included_data.select do |included|
        included['type'] == 'characteristics'
      end

      expect(characteristics.count).to eq(Characteristic.count)
    end
  end
end
