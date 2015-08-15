require 'rails_helper'

RSpec.describe "wicked_problems/show", type: :view do
  before(:each) do
    @problem = assign(:wicked_problem, WickedProblem.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
