require 'rails_helper'

RSpec.describe "problems/show", type: :view do
  before(:each) do
    @problem = assign(:problem, Problem.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
