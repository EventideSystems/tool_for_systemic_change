require 'rails_helper'

RSpec.describe "subsystem_tags/index", type: :view do
  before(:each) do
    assign(:subsystem_tags, [
      SubsystemTag.create!(),
      SubsystemTag.create!()
    ])
  end

  it "renders a list of subsystem_tags" do
    render
  end
end
