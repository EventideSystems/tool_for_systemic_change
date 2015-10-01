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
  let!(:client) { create(:client) }
  let!(:user) { create(:user, client: client) }
  let!(:admin) { create(:admin_user, client: client) }
  let!(:staff) { create(:staff_user) }

  # Resources avaible to user and admin and staff
  let!(:community) { create(:community, client: client) }
  let!(:scorecard) { create(:scorecard,
      client: client,
      community: community) }
  let!(:organisation) { create(:organisation,
    client: client)}
  # let!(:initiative) { create(:initiative, scorecard: scorecard, organisation: organisation )}

  # Resources only avaible to staff
  let!(:other_client) { create(:client) }
  let!(:other_community) { create(:community, client: other_client) }
  let!(:other_scorecard) { create(:scorecard,
      client: other_client,
      community: other_community) }
  let!(:other_organisation) { create(:organisation,
    client: other_client)}
  # let!(:other_initiative) { create(:initiative, scorecard: other_scorecard, organisation: other_organisation )}
end

RSpec.shared_context "setup model data" do
  load "#{Rails.root}/db/model_seeds.rb"
end
