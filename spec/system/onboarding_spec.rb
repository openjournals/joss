require "rails_helper"

feature "Onboarding" do
  let(:user) { create(:user) }
  let(:user_editor) { create(:user, editor: create(:editor)) }
  let(:aeic) { create(:user, editor: create(:board_editor)) }

  scenario "Is not public" do
    visit onboardings_path
    expect(page).to have_content("Please login first")
  end

  scenario "Is not available to non-eic users" do
    login_as(user_editor)
    visit onboardings_path
    expect(page).to have_content("You are not permitted to view that page")
  end

  scenario "Is visible to AEiC" do
    login_as(aeic)
    visit onboardings_path
    expect(page).to_not have_content("You are not permitted to view that page")
    expect(page).to have_content("Invitations to join the editorial team")
  end

  feature "Manage invitations to join the editorial board" do
    before do
      login_as(aeic)
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

      visit onboardings_path
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

    scenario "List pending invitations" do
      create(:onboarding_invitation, email: "invited@editor.org")
      create(:onboarding_invitation, email: "accepted@editor.org", accepted_at: Time.now)

      visit onboardings_path
      within("#onboarding-invitations") {
        expect(page).to have_content("invited@editor.org")
        expect(page).to_not have_content("accepted@editor.org")
      }
    end
  end

  feature "Manage pending editors" do
    let(:pending_editor) { create(:pending_editor, first_name: "Laura", last_name: "Edits", login: "lauraedits33") }

    before do
      login_as(aeic)
      allow(Repository).to receive(:editors).and_return([""])
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

    scenario "Accept pending editor" do
      user = create(:user, editor: pending_editor)
      visit onboardings_path

      within("#pending-editors") do
        expect(page).to have_content("Laura Edits")
        click_link "Approve"
      end

      expect(page).to have_content("Laura Edits (@lauraedits33) accepted as topic editor!")
      expect(page).to_not have_css("#pending-editors")

      create(:pending_editor)
      visit onboardings_path
      within("#pending-editors") do
        expect(page).to_not have_content("Laura Edits")
      end

      visit editors_path
      expect(page).to have_content("lauraedits33")
    end

    scenario "Update editor's info" do
      user = create(:user, editor: pending_editor)
      visit onboardings_path
      within("#pending-editors") do
        expect(page).to have_content("Laura Edits")
        click_link "lauraedits33"
      end
      expect(page).to have_content("Laura Edits")
      click_link "Edit"
      fill_in :editor_first_name, with: "Lauren"
      click_on "Update Editor"
      click_link "List of pending editors"
      expect(current_path).to eq(onboardings_path)
      within("#pending-editors") do
        expect(page).to_not have_content("Laura Edits")
        expect(page).to have_content("Lauren Edits")
      end
    end

    scenario "Invite to GH editors team" do
      user = create(:user, editor: pending_editor)
      onboarding = create(:onboarding_invitation, email: pending_editor.email)
      onboarding.accepted!(pending_editor)

      visit onboardings_path

      expect(onboarding.invited_to_team_at).to be_blank
      expect(Repository).to receive(:invite_to_editors_team).with("lauraedits33").and_return(true)
      within("#pending-editors") do
        expect(page).to have_content("Information registered. Ready to be invited to GitHub team")
        click_link "Send invitation to join GitHub team"
      end

      expect(onboarding.reload.invited_to_team_at).to be_present
      expect(page).to have_content("@lauraedits33 invited to GitHub Open Journals' editors team")

      expect(Repository).to receive(:invite_to_editors_team).with("lauraedits33").and_return(true)
      within("#pending-editors") do
        expect(page).to have_content("Invitation to join organization sent. Pending acceptance.")
        click_link "Re-send invitation to join GitHub organization"
      end

      expect(page).to have_content("@lauraedits33 invited to GitHub Open Journals' editors team")
    end

    scenario "Pending editors already in the GH editors team are detected" do
      user = create(:user, editor: pending_editor)
      expect(Repository).to receive(:editors).and_return(["@lauraedits33"])
      visit onboardings_path

      within("#pending-editors") do
        expect(page).to have_content("Joined GitHub organization and editors team!")
      end
    end
  end

  feature "Invitations acceptance" do
    let(:onboarding_invitation) { create(:onboarding_invitation, email: user.email) }

    before do
      login_as(user)
    end

    scenario "Users can't access other users invitations" do
      inv = create(:onboarding_invitation)
      visit editor_onboardings_path(inv.token)

      expect(page).to have_content("The page you requested is not available")
    end

    scenario "Invitation is not valid if user is already an editor" do
      create(:editor, user: user)
      visit editor_onboardings_path(onboarding_invitation.token)

      expect(page).to have_content("You already are an editor")
    end

    scenario "User can access they own invitations" do
      visit editor_onboardings_path(onboarding_invitation.token)
      expect(page).to have_content("Please complete your editor information")
    end

    scenario "Accepting invitations create a pending editor, tracks enabled" do
      enable_feature(:tracks) do
        track = create(:track)

        visit editor_onboardings_path(onboarding_invitation.token)
        fill_in :editor_first_name, with: "Eddie"
        fill_in :editor_last_name, with: "Tor"
        fill_in :editor_email, with: "edi@tor.com"
        fill_in :editor_login, with: "@test_editor"
        fill_in :editor_url, with: "https://joss.theoj.org"
        fill_in :editor_category_list, with: "bioinformatics, open science"
        fill_in :editor_description, with: "I'm a great person"
        check track.name
        click_on "Save editor data"

        expect(page).to have_content("Thanks! An editor in chief will review your info soon")
        expect(user.editor).to be_pending
        expect(onboarding_invitation.reload).to be_accepted
        expect(onboarding_invitation.editor).to eq(user.editor)
      end
    end

    scenario "Accepting invitations create a pending editor, tracks disabled" do
      disable_feature(:tracks) do
        visit editor_onboardings_path(onboarding_invitation.token)
        fill_in :editor_first_name, with: "Eddie"
        fill_in :editor_last_name, with: "Tor"
        fill_in :editor_email, with: "edi@tor.com"
        fill_in :editor_login, with: "@test_editor"
        fill_in :editor_url, with: "https://joss.theoj.org"
        fill_in :editor_category_list, with: "bioinformatics, open science"
        fill_in :editor_description, with: "I'm a great person"
        click_on "Save editor data"

        expect(page).to have_content("Thanks! An editor in chief will review your info soon")
        expect(user.editor).to be_pending
        expect(onboarding_invitation.reload).to be_accepted
        expect(onboarding_invitation.editor).to eq(user.editor)
      end
    end

    scenario "Pending editors can update their info" do
      user.editor = create(:pending_editor, first_name: "WrongName")

      visit editor_onboardings_path(onboarding_invitation.token)
      fill_in :editor_first_name, with: "UpdatedName"
      fill_in :editor_category_list, with: "astrophysics, galaxies"
      click_on "Save editor data"

      expect(user.editor.reload.first_name).to eq("UpdatedName")
      expect(user.editor.categories).to eq(["astrophysics", "galaxies"])
    end

    scenario "Name, Email, GitHub username are mandatory" do
      enable_feature(:tracks) do
        track = create(:track)
        data = { editor_first_name: "Eddie",
                 editor_last_name: "Tor",
                 editor_email: "edi@tor.com",
                 editor_login: "@test" }

        data.keys.each do |field_name|
          visit editor_onboardings_path(onboarding_invitation.token)
          fields = data.keys - [field_name]
          fields.each do |field|
            fill_in field, with: data[field]
          end
          fill_in field_name, with: nil
          check track.name
          click_on "Save editor data"

          expect(page).to have_content("Error saving your data: Name, Email, GitHub username and Tracks are mandatory")
        end
      end

      disable_feature(:tracks) do
        data = { editor_first_name: "Eddie",
                 editor_last_name: "Tor",
                 editor_email: "edi@tor.com",
                 editor_login: "@test" }

        data.keys.each do |field_name|
          visit editor_onboardings_path(onboarding_invitation.token)
          fields = data.keys - [field_name]
          fields.each do |field|
            fill_in field, with: data[field]
          end
          fill_in field_name, with: nil
          click_on "Save editor data"

          expect(page).to have_content("Error saving your data: Name, Email and GitHub username are mandatory")
        end
      end
    end

    scenario "Tracks are mandatory if tracks are enabled" do
      enable_feature(:tracks) do
        track = create(:track)
        data = { editor_first_name: "Eddie",
                 editor_last_name: "Tor",
                 editor_email: "edi@tor.com",
                 editor_login: "@test" }

        visit editor_onboardings_path(onboarding_invitation.token)
        data.keys.each do |field|
          fill_in field, with: data[field]
        end
        uncheck track.name
        click_on "Save editor data"

        expect(page).to have_content("Error saving your data: Name, Email, GitHub username and Tracks are mandatory")
      end
    end

    scenario "Tracks are not mandatory if tracks are disabled" do
      disable_feature(:tracks) do
        data = { editor_first_name: "Eddie",
                 editor_last_name: "Tor",
                 editor_email: "edi@tor.com",
                 editor_login: "@test" }

        visit editor_onboardings_path(onboarding_invitation.token)
        data.keys.each do |field|
          fill_in field, with: data[field]
        end

        expect {
          click_on "Save editor data"
        }.to change { OnboardingInvitation.pending_acceptance.count }.by(-1)

        expect(page).to have_content("Thanks! An editor in chief will review your info soon")
        expect(page).to_not have_content("Error saving your data")
      end
    end
  end
end
