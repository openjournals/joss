require 'rails_helper'

describe 'papers/submitted.html.erb' do
  before { skip_paper_repo_url_check }

  context 'submitted papers' do
    it "should not show" do
      user = create(:user)

      3.times do
        create(:accepted_paper, submitting_author: user)
      end

      create(:paper, state: "submitted", submitting_author: user)

      assign(:papers, Paper.submitted.paginate(page: 1, per_page: 10))

      render template: "papers/index", formats: :html

      expect(rendered).to have_selector('.paper-title', count: 0)
      expect(rendered).to have_content(:visible, "All Papers 3", normalize_ws: true)
      expect(rendered).to have_content(:visible, "Active Papers 0", normalize_ws: true)
    end
  end
end
