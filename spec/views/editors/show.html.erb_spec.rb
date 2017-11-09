require 'rails_helper'

RSpec.describe "editors/show", type: :view do
  before(:each) do
    @editor = assign(:editor, create(:editor))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/First name/)
    expect(rendered).to match(/Last name/)
    expect(rendered).to match(/Login/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Avatar url/)
    expect(rendered).to match(/Categories/)
    expect(rendered).to match(/Url/)
    expect(rendered).to match(/Description/)
  end
end
