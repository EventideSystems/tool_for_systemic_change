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
      Bullet.enable = false
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

      Bullet.enable = true
    end

    specify "includes recent activity" do

      Bullet.enable = false
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
      Bullet.enable = true
    end

    specify "includes video tutorials" do
      create(:video_tutorial, link_url: "https://vimeo.com/11111", promote_to_dashboard: true)
      create(:video_tutorial, link_url: "https://vimeo.com/22222", promote_to_dashboard: true)
      create(:video_tutorial, link_url: "https://vimeo.com/33333", promote_to_dashboard: true)

      get dashboard_path
      expect(response).to have_http_status(200)

      tutorials = JSON.parse(response.body)['data']['attributes']['videoTutorials']

      expect(tutorials.count).to be(3)
    end
  end
end
