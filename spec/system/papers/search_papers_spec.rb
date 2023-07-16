require "rails_helper"

feature "Paper search" do
  before do
    paper_1 = create(:accepted_paper, title: "Astronomy paper")
    paper_1.metadata['paper']['title'] = "Astronomy paper"
    paper_1.metadata['paper']['authors'] = [{'given_name' => "Vera", 'last_name' => "Rubin"}]
    paper_1.metadata['paper']['tags'] = ["Galaxy rotation curves"]
    paper_1.save!

    paper_2 = create(:accepted_paper, title: "Biodiversity study")
    paper_2.metadata['paper']['title'] = "Biodiversity study"
    paper_2.metadata['paper']['authors'] = [{'given_name' => "Jane", 'last_name' => "Goodall"}]
    paper_2.metadata['paper']['tags'] = ["Wild chimpanzees"]
    paper_2.save!

    Paper.reindex
  end

  scenario "by title" do
    visit published_papers_path
    fill_in :q, with: "Astronomy"
    click_button "search_button"

    expect(page).to have_content("Astronomy paper")
    expect(page).to_not have_content("Biodiversity")

    fill_in :q, with: "Biodiversity"
    click_button "search_button"

    expect(page).to_not have_content("Astronomy")
    expect(page).to have_content("Biodiversity study")
  end

  scenario "by author" do
    visit published_papers_path
    fill_in :q, with: "Vera Rubin"
    click_button "search_button"

    expect(page).to have_content("Astronomy paper")
    expect(page).to_not have_content("Biodiversity")

    fill_in :q, with: "Jane Goodall"
    click_button "search_button"

    expect(page).to_not have_content("Astronomy paper")
    expect(page).to have_content("Biodiversity")
  end

  scenario "by tag" do
    visit published_papers_path
    fill_in :q, with: "rotation curves"
    click_button "search_button"

    expect(page).to have_content("Astronomy paper")
    expect(page).to_not have_content("Biodiversity")

    fill_in :q, with: "chimpanzees"
    click_button "search_button"

    expect(page).to_not have_content("Astronomy paper")
    expect(page).to have_content("Biodiversity")
  end

  feature "Atom feed" do
    scenario "keeps the query param" do
      visit search_papers_path(q: "Vera Rubin")
      click_link "This Search"

      expect(page).to have_current_path(search_papers_path(q: "Vera Rubin", format: :atom))
      expect(page).to have_content("Astronomy")
      expect(page).to_not have_content("Biodiversity study")
    end
  end
end
