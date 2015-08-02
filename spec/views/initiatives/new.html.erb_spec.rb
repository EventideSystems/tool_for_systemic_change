require 'rails_helper'

RSpec.describe "initiatives/new", type: :view do
  before(:each) do
    assign(:initiative, Initiative.new())
  end

  it "renders new initiative form" do
    render

    assert_select "form[action=?][method=?]", initiatives_path, "post" do
    end
  end
end
