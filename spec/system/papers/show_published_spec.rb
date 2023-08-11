require "rails_helper"

feature "Published paper's show page" do
  before do
    @accepted_paper = create(:accepted_paper, title: "Astronomy paper", doi: "10.21105/joss.00001", review_issue_id: 1)
    @accepted_paper.metadata['paper']['title'] = "Astronomy paper"
    @accepted_paper.metadata['paper']['authors'] = [{'given_name' => "Vera", 'last_name' => "Rubin"}]
    @accepted_paper.metadata['paper']['tags'] = ["Galaxy rotation curves"]
    @accepted_paper.save!

    @retracted_paper = create(:retracted_paper, title: "Bad paper", doi: "10.21105/joss.00002", review_issue_id: 2)
    @retracted_paper.metadata['paper']['title'] = "Bad paper"
    @retracted_paper.save!

    @retraction_notice = create(:accepted_paper, title: "Retraction notice for: Bad paper", doi: "10.21105/joss.00002R")
    @retraction_notice.update(retracted_paper: @retracted_paper)
  end

  scenario "Accepted paper" do
    visit paper_path(@accepted_paper)

    expect(page).to have_content("Astronomy paper")
    expect(page).to_not have_content("This paper has been retracted")
    expect(page).to_not have_content("This paper is a retraction notice")

    expect(page).to have_link("Software repository")
    expect(page).to have_link("Paper review")
    expect(page).to have_link("Download paper")
    expect(page).to have_link("Software archive")

    expect(page).to_not have_link("Retraction notice")
    expect(page).to_not have_link("Retracted Paper")
    expect(page).to_not have_link("Download Retraction Notice")
  end

  scenario "Retracted paper" do
    visit paper_path(@retracted_paper)

    expect(page).to have_content("Bad paper")
    expect(page).to have_content("This paper has been retracted")
    expect(page).to_not have_content("This paper is a retraction notice")

    expect(page).to have_link("Software repository")
    expect(page).to have_link("Paper review")
    expect(page).to have_link("Download paper")
    expect(page).to have_link("Software archive")

    expect(page).to have_link("Retraction notice")
    expect(page).to have_link("read details here")

    expect(page).to_not have_link("Retracted Paper")
    expect(page).to_not have_link("Download Retraction Notice")
  end

  scenario "Retraction notice" do
    visit paper_path(@retraction_notice)

    expect(page).to have_content("Retraction notice for: Bad paper")
    expect(page).to have_content("This paper is a retraction notice for: Bad paper")
    expect(page).to_not have_content("This paper has been retracted")

    expect(page).to_not have_link("Software repository")
    expect(page).to_not have_link("Paper review")
    expect(page).to_not have_link("Download paper")
    expect(page).to_not have_link("Software archive")

    expect(page).to_not have_link("Retraction notice")
    expect(page).to_not have_link("read details here")

    expect(page).to have_link("Retracted Paper")
    expect(page).to have_link("Download Retraction Notice")
  end
end
