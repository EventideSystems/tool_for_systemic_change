require 'rails_helper'

RSpec.describe "organisations/show", type: :view do
  before(:each) do
    @organisation = assign(:organisation, Organisation.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
