require 'rails_helper'

RSpec.describe "wicked_problems/new", type: :view do
  before(:each) do
    assign(:wicked_problem, WickedProblem.new())
  end

  it "renders new wicked_problem form" do
    render

    assert_select "form[action=?][method=?]", wicked_problems_path, "post" do
    end
  end
end
