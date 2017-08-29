require 'rails_helper'

RSpec.describe "organisations/imports/show", type: :view do
  before(:each) do
    @organisations_import = assign(:organisations_import, Organisations::Import.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
