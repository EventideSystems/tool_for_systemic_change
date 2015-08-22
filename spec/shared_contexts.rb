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

  # Resources avaible to user and admin and staff
  let!(:community) { create(:community, administrating_organisation: administrating_organisation) }
  let!(:wicked_problem) { create(:wicked_problem,
      administrating_organisation: administrating_organisation,
      community: community) }
  let!(:organisation) { create(:organisation,
    administrating_organisation: administrating_organisation)}
  # let!(:initiative) { create(:initiative, wicked_problem: wicked_problem, organisation: organisation )}

  # Resources only avaible to staff
  let!(:other_administrating_organisation) { create(:administrating_organisation) }
  let!(:other_community) { create(:community, administrating_organisation: other_administrating_organisation) }
  let!(:other_wicked_problem) { create(:wicked_problem,
      administrating_organisation: other_administrating_organisation,
      community: other_community) }
  let!(:other_organisation) { create(:organisation,
    administrating_organisation: other_administrating_organisation)}
  # let!(:other_initiative) { create(:initiative, wicked_problem: other_wicked_problem, organisation: other_organisation )}
end
