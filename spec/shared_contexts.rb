RSpec.shared_context "api request global before and after hooks" do
  before(:each) do
    Warden.test_mode!
  end

  after(:each) do
    Warden.test_reset!
  end
end

RSpec.shared_context "api request authentication helper methods" do
  def sign_in(user)
    login_as(user, scope: :user)
  end

  def sign_out
    logout(:user)
  end
end

RSpec.shared_context "setup common data" do
  let!(:administrating_organisation) { create(:administrating_organisation) }
  let!(:user) { create(:user, administrating_organisation: administrating_organisation) }
  let!(:admin) { create(:admin_user, administrating_organisation: administrating_organisation) }
  let!(:staff) { create(:staff_user) }

  let!(:community) { create(:community, administrating_organisation: administrating_organisation) }
  let!(:wicked_problem) { create(:wicked_problem,
      administrating_organisation: administrating_organisation,
      community: community) }

  let!(:other_administrating_organisation) { create(:administrating_organisation) }
  let!(:other_community) { create(:community, administrating_organisation: other_administrating_organisation) }
  let!(:other_wicked_problem) { create(:wicked_problem,
      administrating_organisation: other_administrating_organisation,
      community: other_community) }
end
