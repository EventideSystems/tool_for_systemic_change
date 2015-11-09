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
      expect(Time.parse(focus_area_data['attributes']['createdAt']).utc).
        to be_within(0.01).of(focus_area.created_at.utc)


      relationships_data = focus_area_data['relationships']

      expect(relationships_data['focusAreaGroup']['data']['id'])
        .to eq(focus_area.focus_area_group.id.to_s)

      # SMELL Partial dupe from checklist_items_spec
      included_data = JSON.parse(response.body)['included']

      focus_area_groups = included_data.select do |included|
        included['type'] == 'focus_area_groups'
      end

      expect(focus_area_groups.count).to eq(FocusAreaGroup.count)

      characteristics = included_data.select do |included|
        included['type'] == 'characteristics'
      end

      expect(characteristics.count).to eq(Characteristic.count)
    end
  end

  describe "GET /focus_areas/:id/video_tutorial" do

    it "returns embedded video link for focus area" do
      focus_area = FocusArea.first
      video_tutorial = create(:video_tutorial, link_url: "https://vimeo.com/11111", linked: focus_area)

      sign_in(admin)
      get video_tutorial_focus_area_path(focus_area)

      attribute_data = JSON.parse(response.body)['data']['attributes']
      expect(attribute_data['vimeoId']).to eq("11111")
    end
  end
end
