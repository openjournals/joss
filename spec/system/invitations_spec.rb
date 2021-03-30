require "rails_helper"

feature "Invitations list" do
  let(:user_editor) { create(:user, editor: create(:editor, first_name: "Lorena")) }
  let(:admin) { create(:admin_user) }

  scenario "Is not public" do
    visit invitations_path
    expect(page).to have_content("Please login first")
  end

  scenario "Is not available to non-eic users" do
    login_as(user_editor)
    visit invitations_path
    expect(page).to have_content("You are not permitted to view that page")
  end

  scenario "Is visible to admins" do
    login_as(admin)
    visit invitations_path
    expect(page).to_not have_content("You are not permitted to view that page")
  end

  feature "Logged as an admin" do
    before do
      create(:editor, first_name: "Tester",
                      login: "tester",
                      description: "Software testing editor",
                      categories: ["Computing", "Test systems"],
                      availability_comment: "Always available")
      login_as(admin)
    end

    scenario "show no invitations message" do
      visit invitations_path
      expect(page).to_not have_content("Invitation status")
      expect(page).to have_content("There are no recent invitations to show")
    end

    scenario "list invitations" do
      create(:invitation, paper: create(:paper, title: "Test paper"), editor: create(:editor, login: "tester1"))
      create(:invitation, paper: create(:paper, title: "Science paper"), editor: create(:editor, login: "user3"))
      visit invitations_path

      expect(page).to have_content("Test paper")
      expect(page).to have_content("tester1")
      expect(page).to have_content("Science paper")
      expect(page).to have_content("user3")
    end

    scenario "show status for accepted invitations" do
      create(:invitation, accepted: true)
      visit invitations_path

      expect(page).to have_content("✅ Accepted")
    end

    scenario "show status for pending invitations" do
      create(:invitation, accepted: false)
      visit invitations_path

      expect(page).to have_content("⏳ Pending")
    end

    scenario "show status for rejected invitations" do
      paper = create(:paper, review_issue_id: 42, editor: create(:editor, id: 33))
      create(:invitation, accepted: false, paper: paper, editor: create(:editor, id: 21))
      visit invitations_path

      expect(page).to have_content("❌ Rejected")
    end
  end
end
