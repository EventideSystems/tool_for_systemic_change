require 'rails_helper'

RSpec.describe Profile, type: :model do

  let(:administrating_organisation) { create(:administrating_organisation) }
  let(:user) { create(:user, administrating_organisation: administrating_organisation) }
  let(:admin) { create(:admin_user, administrating_organisation: administrating_organisation) }
  let(:staff) { create(:staff_user) }

  specify "user profile" do
    profile = Profile.new(user)

    expect(profile.user_email).to eq(user.email)
    expect(profile.user_role).to eq('user')
    expect(profile.administrating_organisation_name).to eq(administrating_organisation.name)
  end

  specify "admin profile" do
    profile = Profile.new(admin)

    expect(profile.user_email).to eq(admin.email)
    expect(profile.user_role).to eq('admin')
    expect(profile.administrating_organisation_name).to eq(administrating_organisation.name)
  end

  specify "staff profile" do
    profile = Profile.new(staff)

    expect(profile.user_email).to eq(staff.email)
    expect(profile.user_role).to eq('staff')
    expect(profile.administrating_organisation_name).to eq('')
  end

end
