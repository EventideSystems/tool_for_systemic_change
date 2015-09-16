require 'rails_helper'
require 'shared_contexts'

RSpec.describe "FocusArea", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"
  include_context "setup model data"

  describe "GET /focus_areas" do

    specify 'all fields returned' do
      sign_in(staff)
      get focus_areas_path

      focus_area = FocusArea.first
      focus_area_data = JSON.parse(response.body)['data'].first

      expect(focus_area_data['id']).to eq(focus_area.id.to_s)
      expect(focus_area_data['attributes']['name']).to eq(focus_area.name)
      expect(focus_area_data['attributes']['description']).to eq(focus_area.description)

      relationships_data = focus_area_data['relationships']

      expect(relationships_data['focusAreaGroup']['data']['id'])
        .to eq(focus_area.focus_area_group.id.to_s)

      included_data = JSON.parse(response.body)['included'].select do |item|
        item['type'] == 'characteristics'
      end

      expect(included_data.count).to eq(Characteristic.count)
    end
  end
end
