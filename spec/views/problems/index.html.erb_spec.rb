require 'rails_helper'

RSpec.describe "problems/index", type: :view do
  before(:each) do
    assign(:problems, [
      Problem.create!(),
      Problem.create!()
    ])
  end

  it "renders a list of problems" do
    render
  end
end
