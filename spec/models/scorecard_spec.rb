require 'rails_helper'

RSpec.describe Scorecard, type: :model do

  specify "shared_link_id created on save" do
    scorecard = build(:scorecard)

    scorecard.save!

    expect(scorecard.shared_link_id).to_not be(nil)
  end

  specify "shared_link_id does not change on update" do
    scorecard = create(:scorecard)
    orig_shared_link_id = scorecard.shared_link_id
    expect(orig_shared_link_id).to_not be(nil)

    scorecard.name = 'new name!!'
    scorecard.save!

    expect(scorecard.shared_link_id).to eq(orig_shared_link_id)
  end

end
