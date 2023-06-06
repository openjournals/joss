require "rails_helper"

feature "Invitations list" do
  before { skip_paper_repo_url_check }
  let(:user_editor) { create(:user, editor: create(:editor, first_name: "Lorena")) }
  let(:aeic) { create(:user, editor: create(:board_editor)) }

  scenario "Is not public" do
    visit invitations_path
    expect(page).to have_content("Please login first")
  end

  scenario "Is not available to non-eic users" do
    login_as(user_editor)
    visit invitations_path
    expect(page).to have_content("You are not permitted to view that page")
  end

  scenario "Is visible to AEiCs" do
    login_as(aeic)
    visit invitations_path
    expect(page).to_not have_content("You are not permitted to view that page")
  end

  feature "Logged as an AEiC" do
    before do
      create(:editor, first_name: "Tester",
                      login: "tester",
                      description: "Software testing editor",
                      categories: ["Computing", "Test systems"],
                      availability_comment: "Always available")
      login_as(aeic)
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

    scenario "expire invitations" do
      invitation = create(:invitation, :pending)
      visit invitations_path

      expect(page).to have_content("⏳ Pending")
      expect(page).to have_link("Cancel", href: expire_invitation_path(invitation))
      click_link "Cancel"
      expect(page).to have_content("Invitation canceled")
      expect(page).to have_content("❌ Expired")
      expect(page).to_not have_link("Cancel")
      expect(page).to_not have_content("⏳ Pending")
    end

    scenario "only pending invitations can be canceled" do
      create(:invitation, :accepted)
      create(:invitation, :expired)
      visit invitations_path

      expect(page).to_not have_link("Cancel")
    end

    scenario "paginate invitations" do
      create_list(:invitation, 10, :accepted)
      create_list(:invitation, 10, :pending)
      create_list(:invitation, 10, :expired)
      visit invitations_path

      expect(page).to have_content("Displaying invitations 1 - 25 of 30 in total")
      expect(page).to have_link("Next →", href: invitations_path(page:2))
    end

    scenario "show status for accepted invitations" do
      create(:invitation, :accepted)
      visit invitations_path

      expect(page).to have_content("✅ Accepted")
    end

    scenario "show status for pending invitations" do
      create(:invitation, :pending)
      visit invitations_path

      expect(page).to have_content("⏳ Pending")
    end

    scenario "show status for expired invitations" do
      create(:invitation, :expired)
      visit invitations_path

      expect(page).to have_content("❌ Expired")
    end
  end
end
