require 'rails_helper'

describe 'papers/show.html.erb' do
  context 'rendering paper status partial' do
    it "displays correctly for submitted paper" do
      paper = create(:paper, :state => "submitted")
      assign(:paper, paper)

      render :template => "papers/show.html.erb"

      expect(rendered).to have_content "but the review hasn't started."
    end

    it "displays correctly for accepted paper" do
      paper = create(:paper, :state => "accepted")
      assign(:paper, paper)

      render :template => "papers/show.html.erb"

      expect(rendered).to have_content "accepted into The Journal of Open Source Software"
    end
  end
end
