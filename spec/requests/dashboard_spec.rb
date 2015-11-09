require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Dashboard", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /dashboard" do
    specify "includes client name" do
      client.welcome_message = <<-MESSAGE
Bacon ipsum dolor amet kielbasa fatback beef ribs.

Biltong sirloin beef ribs swine tri-tip turducken shankle.
MESSAGE
      sign_in(admin)

      get dashboard_path
      expect(response).to have_http_status(200)

      puts JSON.parse(response.body)

      html = JSON.parse(response.body)['data']['attributes']['welcomeMessageHtml']
      expect(html).to eq(
        "<p>Bacon ipsum dolor amet kielbasa fatback beef ribs.</p>\n\n" +
        "<p>Biltong sirloin beef ribs swine tri-tip turducken shankle.</p>\n")

    end
  end
end
