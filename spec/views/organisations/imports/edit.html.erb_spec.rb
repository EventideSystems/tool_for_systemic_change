require 'rails_helper'

RSpec.describe "organisations/imports/edit", type: :view do
  before(:each) do
    @organisations_import = assign(:organisations_import, Organisations::Import.create!())
  end

  it "renders the edit organisations_import form" do
    render

    assert_select "form[action=?][method=?]", organisations_import_path(@organisations_import), "post" do
    end
  end
end
