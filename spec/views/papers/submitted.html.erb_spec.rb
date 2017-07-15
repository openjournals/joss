require 'rails_helper'

describe 'papers/submitted.html.erb' do
  context 'for submitted papers' do
    it 'should show the correct number of papers' do
      3.times do
        create(:paper, state: 'accepted')
      end

      create(:paper, state: 'submitted')

      assign(:papers, Paper.submitted.paginate(page: 1, per_page: 10))

      render template: 'papers/index.html.erb'

      expect(rendered).to have_selector('.paper-title', count: 1)
      expect(rendered).to have_content 'Active papers (1)'
    end
  end
end
