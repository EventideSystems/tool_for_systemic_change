require 'rails_helper'

RSpec.describe "initiatives/imports/edit", type: :view do
  before(:each) do
    @initiatives_import = assign(:initiatives_import, Initiatives::Import.create!())
  end

  it "renders the edit initiatives_import form" do
    render

    assert_select "form[action=?][method=?]", initiatives_import_path(@initiatives_import), "post" do
    end
  end
end
