require 'rails_helper'

RSpec.describe "organisations/index", type: :view do
  before(:each) do
    assign(:organisations, [
      Organisation.create!(),
      Organisation.create!()
    ])
  end

  it "renders a list of organisations" do
    render
  end
end
