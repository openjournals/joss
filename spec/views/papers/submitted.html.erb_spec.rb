require 'rails_helper'

describe 'papers/submitted.html.erb' do
  context 'for submitted papers' do
    it "should show the correct number of papers" do
      user = create(:user)

      3.times do
        create(:paper, :state => "accepted", :submitting_author => user)
      end

      create(:paper, :state => "submitted", :submitting_author => user)

      assign(:papers, Paper.submitted.paginate(:page => 1, :per_page => 10))

      render :template => "papers/index.html.erb"

      expect(rendered).to have_selector('.paper-title', :count => 0)
      expect(rendered).to have_content "Active Papers 1"
    end
  end
end
