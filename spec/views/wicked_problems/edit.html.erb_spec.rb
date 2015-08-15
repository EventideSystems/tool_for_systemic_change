require 'rails_helper'

RSpec.describe "wicked_problems/edit", type: :view do
  before(:each) do
    @wicked_problem = assign(:wicked_problem, WickedProblem.create!())
  end

  it "renders the edit wicked problem form" do
    render

    assert_select "form[action=?][method=?]", wicked_problem_path(@wicked_problem), "post" do
    end
  end
end
