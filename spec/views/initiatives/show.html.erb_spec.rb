require 'rails_helper'

RSpec.describe "initiatives/show", type: :view do
  before(:each) do
    @initiative = assign(:initiative, Initiative.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
