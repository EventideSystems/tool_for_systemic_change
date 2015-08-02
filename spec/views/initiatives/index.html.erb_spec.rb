require 'rails_helper'

RSpec.describe "initiatives/index", type: :view do
  before(:each) do
    assign(:initiatives, [
      Initiative.create!(),
      Initiative.create!()
    ])
  end

  it "renders a list of initiatives" do
    render
  end
end
