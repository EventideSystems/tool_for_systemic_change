require 'rails_helper'

RSpec.describe "subsystem_tags/edit", type: :view do
  before(:each) do
    @subsystem_tag = assign(:subsystem_tag, SubsystemTag.create!())
  end

  it "renders the edit subsystem_tag form" do
    render

    assert_select "form[action=?][method=?]", subsystem_tag_path(@subsystem_tag), "post" do
    end
  end
end
