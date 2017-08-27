require 'rails_helper'

RSpec.describe "organisations/imports/new", type: :view do
  before(:each) do
    assign(:organisations_import, Organisations::Import.new())
  end

  it "renders new organisations_import form" do
    render

    assert_select "form[action=?][method=?]", organisations_imports_path, "post" do
    end
  end
end
