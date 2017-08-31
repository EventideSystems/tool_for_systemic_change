require 'rails_helper'

RSpec.describe "initiatives/imports/show", type: :view do
  before(:each) do
    @initiatives_import = assign(:initiatives_import, Initiatives::Import.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
