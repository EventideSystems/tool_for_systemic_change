require 'rails_helper'

RSpec.describe "initiatives/edit", type: :view do
  before(:each) do
    @initiative = assign(:initiative, Initiative.create!())
  end

  it "renders the edit initiative form" do
    render

    assert_select "form[action=?][method=?]", initiative_path(@initiative), "post" do
    end
  end
end
