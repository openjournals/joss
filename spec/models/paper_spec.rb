require 'rails_helper'

describe Paper do
  before(:each) do
    Paper.destroy_all
  end

  it { should belong_to(:submitting_author) }

  it "should know how to parameterize itself properly" do
    paper = create(:paper)

    expect(paper.sha).to eq(paper.to_param)
  end

  it "should return it's submitting_author" do
    user = create(:user)
    paper = create(:paper, :user_id => user.id)

    expect(paper.submitting_author).to eq(user)
  end

  # Scopes

  it "should return recent" do
    old_paper = create(:paper, :created_at => 2.weeks.ago)
    new_paper = create(:paper)

    expect(Paper.recent).to eq([new_paper])
  end
end
