require 'rails_helper'

RSpec.describe "communities/index", type: :view do
  before(:each) do
    assign(:communities, [
      Community.create!(),
      Community.create!()
    ])
  end

  it "renders a list of communities" do
    render
  end
end
