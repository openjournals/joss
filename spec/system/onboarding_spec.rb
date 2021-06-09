require "rails_helper"

feature "Onboarding" do
  let(:user_editor) { create(:user, editor: create(:editor)) }
  let(:admin) { create(:admin_user) }

  scenario "Is not public" do
    visit onboardings_path
    expect(page).to have_content("Please login first")
  end

  scenario "Is not available to non-eic users" do
    login_as(user_editor)
    visit onboardings_path
    expect(page).to have_content("You are not permitted to view that page")
  end

  scenario "Is visible to admins" do
    login_as(admin)
    visit onboardings_path
    expect(page).to_not have_content("You are not permitted to view that page")
    expect(page).to have_content("Invitations to join the editorial team")
  end

  feature "Manage invitations to join the editorial board" do
    before do
      login_as(admin)
    end

    scenario "Create onboarding invitation" do
      emails_sent = ActionMailer::Base.deliveries.count

      visit onboardings_path
      fill_in :onboarding_invitation_email, with: "new@editor.org"
      fill_in :onboarding_invitation_name, with: "J.R."
      click_on "Invite"

      expect(page).to have_content("Invitation to join the editorial team sent")
      within("#onboarding-invitations") do
        expect(page).to have_content("new@editor.org")
        expect(page).to have_content("J.R.")
      end

      expect(ActionMailer::Base.deliveries.count).to eq(emails_sent + 1)
    end

    scenario "Emails can't be duplicated" do
      create(:onboarding_invitation, email: "abc@def.com")

      visit onboardings_path
      fill_in :onboarding_invitation_email, with: "abc@def.com"
      click_on "Invite"

      expect(page).to have_content("Email is already present in the list on sent invitations")
    end

    scenario "Delete onboarding invitation" do
      create(:onboarding_invitation, email: "editor@dele.te")
      visit onboardings_path
      within("#onboarding-invitations") {
        expect(page).to have_content("editor@dele.te")
        click_link "Delete"
      }

      expect(page).to have_content("Onboarding invitation deleted")
      expect(page).to_not have_content("editor@dele.te")
    end

    scenario "Resend onboarding invitation" do
      create(:onboarding_invitation, email: "invited@editor.org")
      emails_sent = ActionMailer::Base.deliveries.count

      visit onboardings_path
      within("#onboarding-invitations") {
        expect(page).to have_content("invited@editor.org")
        click_link "Re-invite"
      }
      expect(page).to have_content("Email sent again")

      expect(ActionMailer::Base.deliveries.count).to eq(emails_sent + 1)
      expect(ActionMailer::Base.deliveries.last.to).to eq(["invited@editor.org"])
    end
  end

  feature "Manage pending editors" do
    before do
      login_as(admin)
    end

    scenario "List pending editors" do
      create(:editor, first_name: "TopicEditor", last_name: "1")
      create(:pending_editor, first_name: "PendingEditor", last_name: "2")
      visit onboardings_path

      within("#pending-editors") do
        expect(page).to have_content("PendingEditor 2")
        expect(page).to_not have_content("TopicEditor")
      end
    end
  end
end