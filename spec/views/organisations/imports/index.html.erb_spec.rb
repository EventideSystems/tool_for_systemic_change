require 'rails_helper'

RSpec.describe "organisations/imports/index", type: :view do
  before(:each) do
    assign(:organisations_imports, [
      Organisations::Import.create!(),
      Organisations::Import.create!()
    ])
  end

  it "renders a list of organisations/imports" do
    render
  end
end
