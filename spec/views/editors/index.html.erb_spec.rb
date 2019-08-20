require 'rails_helper'

RSpec.describe "editors/index", type: :view do
  before(:each) do
    assign(:editors, create_list(:editor, 2))
  end

  it "renders a list of editors" do
    render
    assert_select "tr>td:nth-of-type(1)", text: "topic", count: 2
    assert_select "tr>td:nth-of-type(2)", text: "Person", count: 2
    assert_select "tr>td:nth-of-type(3)", text: "McEditor", count: 2
    assert_select "tr>td:nth-of-type(4)", text: "mceditor", count: 2
    assert_select "tr>td:nth-of-type(5)", text: "topic1, topic2, topic3", count: 2
  end
end
