require 'rails_helper'

describe 'papers/show.html.erb' do
  before(:each) do
    allow(Repository).to receive(:editors).and_return ["@user1", "@user2"]
  end

  context 'rendering paper status partial' do
    it "displays correctly for submitted paper" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      paper = create(:paper, :state => "submitted", :submitting_author => user)
      assign(:paper, paper)

      render :template => "papers/show.html.erb"

      expect(rendered).to have_content "but the review hasn't started."
    end

    it "displays correctly for accepted paper" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      paper = create(:paper, :state => "accepted")
      assign(:paper, paper)

      render :template => "papers/show.html.erb"

      expect(rendered).to have_content "accepted into The Journal of Open Source Software"
    end
  end

  context 'rendering admin partial' do
    it "displays buttons when there's no GitHub issue" do
      user = create(:user, :admin => true)
      author = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      paper = create(:paper, :state => "submitted", :review_issue_id => nil, :submitting_author => author)
      assign(:paper, paper)

      render :template => "papers/show.html.erb"

      expect(rendered).to have_selector("input[type=submit][value='Reject paper']")
    end

    it "shows the withdraw button to paper owners" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      paper = create(:paper, :state => "submitted", :submitting_author => user)
      assign(:paper, paper)

      render :template => "papers/show.html.erb"
      expect(rendered).to have_selector("input[type=submit][value='Withdraw paper']")
    end

    it "shows the withdraw button to admins" do
      user = create(:user, :admin => true)
      author = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      paper = create(:paper, :state => "submitted", :submitting_author => author)
      assign(:paper, paper)

      render :template => "papers/show.html.erb"
      expect(rendered).to have_selector("input[type=submit][value='Withdraw paper']")
      expect(rendered).to have_content(author.email)
    end

    it "doesn't displays buttons when there's a GitHub issue" do
      user = create(:user, :admin => true)
      author = create(:user)

      allow(view).to receive_message_chain(:current_user).and_return(user)

      paper = create(:paper, :state => "submitted", :review_issue_id => 123, :submitting_author => author)
      assign(:paper, paper)

      render :template => "papers/show.html.erb"

      expect(rendered).to have_content "View review issue"
    end
  end
end
