require 'rails_helper'

describe 'papers/show.html.erb' do
  before(:each) do
    allow(Repository).to receive(:editors).and_return ["@user1", "@user2"]
  end

  context 'rendering paper status partial' do
    it "displays correctly for submitted paper" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      paper = create(:paper, state: "submitted", submitting_author: user)
      assign(:paper, paper)

      render template: "papers/show", formats: :html

      expect(rendered).to have_content(:visible, "but the review hasn't started.", normalize_ws: true)
    end

    it "displays correctly for accepted paper" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      paper = create(:accepted_paper)
      assign(:paper, paper)

      render template: "papers/show", formats: :html

      # Paper metadata
      # FIXME - these tests seem to be timezone sensitive??? i.e. can fail depending
      # upon the time of day when running the tests...
      expect(rendered).to have_content "Submitted #{Time.now.strftime('%d %B %Y')}"
      expect(rendered).to have_content "Published #{Time.now.strftime('%d %B %Y')}"
      expect(rendered).to have_content "Ruby"
      expect(rendered).to have_content "Editor: @arfon (all papers)"
      expect(rendered).to have_content "Reviewers: @jim (all reviews), @jane (all reviews)"
      expect(rendered).to have_content "Walt Elias Disney"
    end

    it "has the correct Google Scholar tags" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      paper = create(:accepted_paper)
      assign(:paper, paper)

      render template: "papers/show", formats: :html

      # Paper metadata
      expect(rendered).to have_title("The Journal of Open Source Software: #{paper.scholar_title}")

      expect(rendered).to have_css("meta[name='citation_title']", visible: false)
      expect(rendered).to have_css("meta[content='#{paper.scholar_title}']", visible: false)

      expect(rendered).to have_css("meta[name='citation_author']", visible: false)
      expect(rendered).to have_css("meta[content='Mickey Mouse']", visible: false)
      expect(rendered).to have_css("meta[content='Walt Elias Disney']", visible: false)

      expect(rendered).to have_css("meta[name='citation_publication_date']", visible: false)
      expect(rendered).to have_css("meta[content='#{paper.accepted_at.strftime('%Y/%m/%d')}']", visible: false)

      expect(rendered).to have_css("meta[name='citation_journal_title']", visible: false)
      expect(rendered).to have_css("meta[content='#{Rails.application.settings['name']}']", visible: false)


      expect(rendered).to have_css("meta[name='citation_pdf_url']", visible: false)
      expect(rendered).to have_css("meta[content='#{paper.seo_pdf_url}']", visible: false)

      expect(rendered).to have_css("meta[name='citation_doi']", visible: false)
      expect(rendered).to have_css("meta[content='10.21105/jose.00000']", visible: false)

      expect(rendered).to have_css("meta[name='citation_issn']", visible: false)
      expect(rendered).to have_css("meta[content='#{Rails.application.settings['issn']}']", visible: false)
    end
  end

  context 'rendering admin partial' do
    it "displays buttons when there's no GitHub issue" do
      user = create(:user, admin: true)
      author = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      paper = create(:paper, state: "submitted", review_issue_id: nil, submitting_author: author)
      assign(:paper, paper)

      render template: "papers/show", formats: :html

      expect(rendered).to have_selector("input[type=submit][value='Reject paper']")
    end

    it "shows the withdraw button to paper owners" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      paper = create(:paper, state: "submitted", submitting_author: user)
      assign(:paper, paper)

      render template: "papers/show", formats: :html
      expect(rendered).to have_selector("input[type=submit][value='Withdraw paper']")
    end

    it "shows the withdraw button to admins" do
      user = create(:user, admin: true)
      editor = create(:editor, user: user)
      author = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      paper = create(:paper, state: "submitted", submitting_author: author)
      assign(:paper, paper)

      render template: "papers/show", formats: :html
      expect(rendered).to have_selector("input[type=submit][value='Withdraw paper']")
      expect(rendered).to have_content(author.email)
    end

    it "doesn't displays buttons when there's a GitHub issue" do
      user = create(:user, admin: true)
      author = create(:user)

      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      paper = create(:resubmission_paper, state: "submitted", review_issue_id: 123, submitting_author: author)
      assign(:paper, paper)

      render template: "papers/show", formats: :html

      expect(rendered).to have_content "Paper review"
      expect(rendered).to have_content "Resubmission"
    end

    it "shows the takedown notice for a retracted paper" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      paper = create(:retracted_paper, retraction_notice: "Reasons for retraction")
      assign(:paper, paper)

      render template: "papers/show", formats: :html
      expect(rendered).to have_content("Reasons for retraction")
    end
  end
end
