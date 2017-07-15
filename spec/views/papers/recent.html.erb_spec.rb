require 'rails_helper'

describe 'papers/recent.html.erb' do
  context 'for recent papers' do
    it 'should show the correct number of papers' do
      3.times do
        create(:paper, state: 'accepted')
      end

      assign(:papers, Paper.all.paginate(page: 1, per_page: 10))

      render template: 'papers/index.html.erb'

      expect(rendered).to have_selector('.paper-title', count: 3)
      expect(rendered).to have_content 'Accepted papers (3)'
    end
  end
end
