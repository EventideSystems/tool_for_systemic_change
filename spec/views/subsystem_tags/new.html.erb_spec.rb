require 'rails_helper'

RSpec.describe "subsystem_tags/new", type: :view do
  before(:each) do
    assign(:subsystem_tag, SubsystemTag.new())
  end

  it "renders new subsystem_tag form" do
    render

    assert_select "form[action=?][method=?]", subsystem_tags_path, "post" do
    end
  end
end
