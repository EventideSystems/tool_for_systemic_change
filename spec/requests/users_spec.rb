require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Users", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "GET /users" do

    specify 'all fields returned' do
      sign_in(user)
      sign_in(staff)
      get users_path

      users_data = JSON.parse(response.body)['data'].find{ |u| u['id'].to_i == user.id }

      expect(users_data['id']).to eq(user.id.to_s)
      expect(users_data['attributes']['name']).to eq(user.name)
      expect(users_data['attributes']['role']).to eq(user.role)
      expect(DateTime.parse(users_data['attributes']['createdAt']).to_s(:db))
        .to eq(user.created_at.to_s(:db))
      expect(DateTime.parse(users_data['attributes']['updatedAt']).to_s(:db))
        .to eq(user.updated_at.to_s(:db))
      expect(DateTime.parse(users_data['attributes']['createdAt']).to_s(:db))
        .to eq(user.created_at.to_s(:db))

      relationships_data = users_data['relationships']

      expect(relationships_data['client']['data']['id'])
        .to eq(user.client.id.to_s)
    end

    describe "restrict access by role" do
      specify "user profile" do
        sign_in(user)
        get users_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(1)
      end

      specify "admin profile" do
        sign_in(admin)
        get users_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(2)
      end

      specify "staff profile - before client context swtitch " do
        sign_in(staff)
        put current_client_path, id: admin.client.id
        get users_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(2)
      end

      specify "staff profile - after client context swtitch " do
        sign_in(staff)
        put current_client_path, id: other_community.client.id
        get users_path

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['data'].count).to be(0)
      end
    end
  end

  describe "DELETE /users/:id" do

    describe "delete user" do
      let!(:user_to_delete) { create(:user, client: admin.client) }

      specify "admin can delete user in same client" do
        sign_in(admin)

        expect do
          delete user_path(user_to_delete)
        end.to change{User.count}.by(-1)

        expect(response).to have_http_status(200)
      end

      specify "admin cannot delete user in different client" do
        sign_in(admin)

        other_user = create(:user, client: other_client)

        expect do
          delete user_path(other_user)
        end.to change{User.count}.by(0)

        expect(response).to have_http_status(403)
      end

      specify "admin cannot delete themselves" do
        sign_in(admin)

        expect do
          delete user_path(admin)
        end.to change{User.count}.by(0)

        expect(response).to have_http_status(403)
      end

      specify "staff can delete users" do
        sign_in(staff)

        expect do
          delete user_path(user_to_delete)
        end.to change{User.count}.by(-1)

        expect(response).to have_http_status(200)
      end

      specify "users cannot delete users" do
        sign_in(user)

        expect do
          delete user_path(user_to_delete)
        end.to change{User.count}.by(0)

        expect(response).to have_http_status(403)
      end
    end
  end

  describe "GET /users/:id/resend_invitation" do

    let!(:invited_user) do
      user = create(:user, client: admin.client)
      user.invite!
      user
    end

    specify "staff can resend invitations" do
      sign_in(staff)

      expect do
        post resend_invitation_user_path(invited_user)
      end.to change{ Delayed::Job.count}.by(1)
      expect(response).to have_http_status(200)
    end

    specify "admin can resend invitations" do
      sign_in(admin)

      expect do
        post resend_invitation_user_path(invited_user)
      end.to change{ Delayed::Job.count}.by(1)
      expect(response).to have_http_status(200)
    end

    specify "admin cannot resend invitation to user in different client" do
      sign_in(admin)

      other_user = create(:user, client: other_client)
      other_user.invite!

      expect do
        post resend_invitation_user_path(other_user)
      end.to change{ Delayed::Job.count}.by(0)
      expect(response).to have_http_status(403)
    end

    specify "users cannot resend invitations" do
      sign_in(user)

      expect do
        post resend_invitation_user_path(invited_user)
      end.to change{ Delayed::Job.count}.by(0)
      expect(response).to have_http_status(403)
    end
  end
end
