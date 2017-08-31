require 'rails_helper'

RSpec.describe "initiatives/imports/new", type: :view do
  before(:each) do
    assign(:initiatives_import, Initiatives::Import.new())
  end

  it "renders new initiatives_import form" do
    render

    assert_select "form[action=?][method=?]", initiatives_imports_path, "post" do
    end
  end
end
