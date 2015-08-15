require 'rails_helper'

RSpec.describe "wicked_problems/index", type: :view do
  before(:each) do
    assign(:wicked_problems, [
      WickedProblem.create!(),
      WickedProblem.create!()
    ])
  end

  it "renders a list of wicked_problems" do
    render
  end
end
