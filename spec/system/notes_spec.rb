require "rails_helper"

feature "Editor notes on papers" do
  before { skip_paper_repo_url_check }
  let(:paper) { create(:review_pending_paper) }
  let(:editor_user) { create(:user, editor: create(:editor)) }

  scenario "Are not public" do
    visit paper_path(paper.sha)
    expect(page).to_not have_content("Editor notes")
  end

  scenario "Are not visible to non editors" do
    login_as(create(:user))
    visit paper_path(paper.sha)
    expect(page).to_not have_content("Editor notes")
  end

  scenario "Are visible to editors" do
    login_as(editor_user)
    visit paper_path(paper.sha)
    expect(page).to have_content("Editor notes")
  end

  scenario "Are not visible for published papers" do
    paper = create(:accepted_paper)
    login_as(editor_user)
    visit paper_path(paper.sha)
    expect(page).to_not have_content("Editor notes")
  end

  scenario "Can be created and deleted by editors" do
    login_as(editor_user)
    visit paper_path(paper.sha)
    fill_in "note_comment", with: "This is a test editor note"
    click_on "Add note"
    expect(page).to have_content("Note saved")

    visit paper_path(paper.sha)
    within("table#paper-notes") do
      expect(page).to have_content("This is a test editor note")
      click_on "Delete note"
    end
    expect(page).to have_content("Note deleted")

    visit paper_path(paper.sha)
    expect(page).to_not have_content("This is a test editor note")
  end

  scenario "Editors can not delete other editor's notes" do
    note = create(:note)
    login_as(editor_user)
    visit paper_path(note.paper.sha)

    expect(page).to have_content(note.comment)
    expect(page).to_not have_content("Delete note")
  end
end