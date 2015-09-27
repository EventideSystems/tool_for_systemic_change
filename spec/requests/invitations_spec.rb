require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Invitations", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "POST /invitations" do

    before(:each) do
      allow_any_instance_of(InvitationsController).to receive(:resource_name).and_return(:user)
      sign_in(admin)
    end

    describe "as an admin user" do
      specify "sends email to invited admin user - no role specified" do
        invited_email = FFaker::Internet.email

        post user_invitation_path, user: {
          email: invited_email
        }, format: :json
        expect(response).to have_http_status(201)

        invited_user = User.last
        expect(invited_user.email).to eq(invited_email)
        expect(invited_user.invited_by_id).to eq(admin.id)
        expect(invited_user.client_id).to eq(client.id)
        expect(invited_user.role).to eq('user')
      end

      specify "sends email to invited admin user - admin role specified" do
        invited_email = FFaker::Internet.email

        post user_invitation_path, user: {
          email: invited_email,
          role: 'admin'
        }, format: :json
        expect(response).to have_http_status(201)

        invited_user = User.last
        expect(invited_user.email).to eq(invited_email)
        expect(invited_user.invited_by_id).to eq(admin.id)
        expect(invited_user.client_id).to eq(client.id)
        expect(invited_user.role).to eq('admin')
      end
    end
  end
end
