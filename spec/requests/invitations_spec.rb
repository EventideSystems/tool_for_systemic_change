require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Invitations", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "POST /invitations" do

    before(:each) do
      allow_any_instance_of(InvitationsController).to receive(:resource_name).and_return(:user)
    end

    describe "as a normal user" do

      specify "prevents any invitation" do
        sign_in(user)

        invited_email = FFaker::Internet.email

        post user_invitation_path, user: {
          email: invited_email
        }, format: :json
        expect(response).to have_http_status(403)

      end
    end

    describe "as an admin user" do

      before(:each) do
        sign_in(admin)
      end

      specify "invites user - no role specified" do
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

      specify "invites user with optional name parameter" do
        invited_email = FFaker::Internet.email
        invited_name = FFaker::Name.name

        post user_invitation_path, user: {
          email: invited_email,
          name: invited_name
        }, format: :json
        expect(response).to have_http_status(201)

        invited_user = User.last
        expect(invited_user.name).to eq(invited_name)
      end

      specify "invites admin user - admin role specified" do
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

      specify "prevents invite for staff user" do
        invited_email = FFaker::Internet.email

        post user_invitation_path, user: {
          email: invited_email,
          role: 'staff'
        }, format: :json
        expect(response).to have_http_status(403)
      end

      specify "delivers invitation asynchronously" do
        expect(Delayed::Job.count).to eq(0)
        invited_email = FFaker::Internet.email

        post user_invitation_path, user: {
          email: invited_email,
          role: 'admin'
        }, format: :json

        expect(Delayed::Job.count).to eq(1)
        Delayed::Worker.new.work_off
        expect(Delayed::Job.count).to eq(0)
      end
    end

    describe "as a staff user" do

      before(:each) do
        sign_in(staff)
      end

      specify "invites admin user - no role specified" do
        invited_email = FFaker::Internet.email

        post user_invitation_path, user: {
          email: invited_email,
          client_id: client.id
        }, format: :json
        expect(response).to have_http_status(201)

        invited_user = User.last
        expect(invited_user.email).to eq(invited_email)
        expect(invited_user.invited_by_id).to eq(staff.id)
        expect(invited_user.client_id).to eq(client.id)
        expect(invited_user.role).to eq('user')
      end

      specify "invites admin user - admin role specified" do
        invited_email = FFaker::Internet.email

        post user_invitation_path, user: {
          email: invited_email,
          role: 'admin',
          client_id: client.id
        }, format: :json
        expect(response).to have_http_status(201)

        invited_user = User.last
        expect(invited_user.email).to eq(invited_email)
        expect(invited_user.invited_by_id).to eq(staff.id)
        expect(invited_user.client_id).to eq(client.id)
        expect(invited_user.role).to eq('admin')
      end

      specify "invites admin user - staff role specified" do
        invited_email = FFaker::Internet.email

        post user_invitation_path, user: {
          email: invited_email,
          role: 'staff'
        }, format: :json
        expect(response).to have_http_status(201)

        invited_user = User.last
        expect(invited_user.email).to eq(invited_email)
        expect(invited_user.invited_by_id).to eq(staff.id)
        expect(invited_user.client_id).to eq(nil)
        expect(invited_user.role).to eq('staff')
      end
    end
  end

  describe "Listing invited users" do

    specify 'invited users have status of invitation-pending' do
      sign_in(staff)
      allow_any_instance_of(InvitationsController).to receive(:resource_name).and_return(:user)
      invited_email = FFaker::Internet.email

      post user_invitation_path, user: {
        email: invited_email,
        client_id: client.id
      }, format: :json

      get users_path

      users_data = JSON.parse(response.body)['data'].find{ |u| u['attributes']['email'] == invited_email }

      expect(users_data['attributes']['status']).to eq('invitation-pending')
    end
  end
end
