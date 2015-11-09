require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Dashboard", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /dashboard" do

    before(:each) do
      sign_in(admin)
    end

    specify "includes client name" do
      client.welcome_message = <<-MESSAGE
Bacon ipsum dolor amet kielbasa fatback beef ribs.

Biltong sirloin beef ribs swine tri-tip turducken shankle.
MESSAGE


      get dashboard_path
      expect(response).to have_http_status(200)

      html = JSON.parse(response.body)['data']['attributes']['welcomeMessageHtml']
      expect(html).to eq(
        "<p>Bacon ipsum dolor amet kielbasa fatback beef ribs.</p>\n\n" +
        "<p>Biltong sirloin beef ribs swine tri-tip turducken shankle.</p>\n")

    end

    specify "includes recent activity" do

      data_attributes = {
        type: 'communities',
        attributes: {
          name: 'blank for now',
          description: 'blank for now'
        },
        relationships: {
          client: { data: { id: client.id } }
        }
      }


      20.times do
        data_attributes[:attributes].merge!(name: FFaker::Lorem.words(4).join(' '),
          description: FFaker::Lorem.words(10).join(' ')
        )

        post '/communities', data: data_attributes
      end

      get dashboard_path
      activities = JSON.parse(response.body)['data']['attributes']['activities']

      expect(activities.count).to be(10)
    end
  end
end
