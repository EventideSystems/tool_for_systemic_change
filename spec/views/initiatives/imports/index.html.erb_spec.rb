require 'rails_helper'

RSpec.describe "initiatives/imports/index", type: :view do
  before(:each) do
    assign(:initiatives_imports, [
      Initiatives::Import.create!(),
      Initiatives::Import.create!()
    ])
  end

  it "renders a list of initiatives/imports" do
    render
  end
end
