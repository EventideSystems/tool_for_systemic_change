require 'rails_helper'

RSpec.describe Profile, type: :model do

  let(:client) { create(:client) }
  let(:user) { create(:user, client: client) }
  let(:admin) { create(:admin_user, client: client) }
  let(:staff) { create(:staff_user) }

  specify "user profile" do
    profile = Profile.new(user)

    expect(profile.user_email).to eq(user.email)
    expect(profile.user_role).to eq('user')
    expect(profile.client_name).to eq(client.name)
  end

  specify "admin profile" do
    profile = Profile.new(admin)

    expect(profile.user_email).to eq(admin.email)
    expect(profile.user_role).to eq('admin')
    expect(profile.client_name).to eq(client.name)
  end

  specify "staff profile" do
    profile = Profile.new(staff)

    expect(profile.user_email).to eq(staff.email)
    expect(profile.user_role).to eq('staff')
    expect(profile.client_name).to eq('')
  end

end
