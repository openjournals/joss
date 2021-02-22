require 'rails_helper'

RSpec.describe "editors/index", type: :view do
  before(:each) do
    assign(:editors, create_list(:editor, 2))
  end

  it "renders a list of editors" do
    render
    assert_select "tr>td:nth-of-type(1)", text: /Person McEditor/, count: 2
    assert_select "tr>td:nth-of-type(2)", text: "mceditor", count: 2
    assert_select "tr>td:nth-of-type(3)", text: "topic1, topic2, topic3", count: 2
    assert_select "tr>td:nth-of-type(5)", text: "Available OOO until March 1", count: 2
  end
end
