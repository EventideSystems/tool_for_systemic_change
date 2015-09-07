require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Invitations", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "POST /invitations" do


    specify "sends email to invited admin user" do
      allow_any_instance_of(InvitationsController).to receive(:resource_name).and_return(:user)

      sign_in(admin)

      invited_email = FFaker::Internet.email

      post user_invitation_path, user: {
        email: invited_email
      }, format: :json
      expect(response).to have_http_status(201)

      expect(User.last.email).to eq(invited_email)
      expect(User.last.invited_by_id).to eq(admin.id)
      expect(User.last.administrating_organisation_id).to eq(administrating_organisation.id)
    end

  end
end
