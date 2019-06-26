require 'rails_helper'

RSpec.describe "editors/index", type: :view do
  before(:each) do
    assign(:editors, create_list(:editor, 2))
  end

  it "renders a list of editors" do
    render
    assert_select "tr>td:nth-of-type(1)", :text => "topic", :count => 2
    assert_select "tr>td:nth-of-type(2)", :text => "", :count => 2
    assert_select "tr>td:nth-of-type(3)", :text => "Person", :count => 2
    assert_select "tr>td:nth-of-type(4)", :text => "McEditor", :count => 2
    assert_select "tr>td:nth-of-type(5)", :text => "mceditor", :count => 2
    assert_select "tr>td:nth-of-type(6)", :text => "mceditor@example.com", :count => 2
    assert_select "tr>td:nth-of-type(7)", :text => "topic1, topic2, topic3", :count => 2
    assert_select "tr>td:nth-of-type(8)", :text => "Person McEditor is an editor", :count => 2
  end
end
