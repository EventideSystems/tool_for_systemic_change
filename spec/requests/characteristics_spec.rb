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

      # expect(relationships_data['client']['data']['id'])
      #   .to eq(client.id.to_s)
      #
      # expect(relationships_data['wickedProblems']['data'].first['id'])
      #   .to eq(wicked_problem.id.to_s)
    end
  end
end
