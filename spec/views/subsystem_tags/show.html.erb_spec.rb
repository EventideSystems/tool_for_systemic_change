require 'rails_helper'

RSpec.describe "subsystem_tags/show", type: :view do
  before(:each) do
    @subsystem_tag = assign(:subsystem_tag, SubsystemTag.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
