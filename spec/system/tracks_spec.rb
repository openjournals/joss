require "rails_helper"

feature "Manage Tracks" do
  before { skip_paper_repo_url_check }
  let(:user_editor) { create(:user, editor: create(:editor, first_name: "Lorena", description: "Science testing editor")) }
  let(:admin_editor) { create(:admin_user, editor: create(:board_editor)) }

  scenario "Is not public" do
    visit tracks_path
    expect(page).to have_content("Please login first")
  end

  scenario "Is not available to non-eic users" do
    login_as(user_editor)
    visit tracks_path
    expect(page).to have_content("You are not permitted to view that page")
  end

  scenario "Is visible to admins" do
    login_as(admin_editor)
    visit tracks_path
    expect(page).to_not have_content("You are not permitted to view that page")
    expect(page).to have_content("Tracks")
  end

  feature "Logged as an admin" do
    before do
      @aeic = create(:board_editor, first_name: "Testeditor", last_name: "In-chief")
      @track = create(:track, name: "Testing track", short_name: "TE", code: "33", aeic_ids: [@aeic.id])
      login_as(admin_editor)
      visit tracks_path
    end

    scenario "Show the list of tracks" do
      expect(page).to have_content("Testing track")
      expect(page).to have_content("TE")
      expect(page).to have_content("33")
    end

    scenario "Show track's info" do
      click_link "Testing track"
      expect(current_path).to eq(track_path(@track))
      expect(page).to have_content("Testing track")
      expect(page).to have_content("TE")
      expect(page).to have_content("33")
      expect(page).to have_content("Testeditor In-chief")
      click_link "List"
      expect(current_path).to eq(tracks_path)
    end

    scenario "Update track info" do
      within("#track_#{@track.id}") {
        click_link "Edit"
      }
      expect(current_path).to eq(edit_track_path(@track))
      fill_in :track_short_name, with: "TESTR"
      click_on "Update Track"
      expect(page).to have_content("Track was successfully updated.")
      click_link "List"
      expect(current_path).to eq(tracks_path)
      within("#track_#{@track.id}") {
        expect(page).to have_content("TESTR")
      }
    end

    scenario "Create track" do
      click_on "New Track"
      expect(current_path).to eq(new_track_path)

      fill_in :track_name, with: "Test Software"
      fill_in :track_short_name, with: "TS"
      fill_in :track_code, with: "42"
      check "Testeditor In-chief"

      click_on "Create Track"

      expect(page).to have_content("Track was successfully created.")
      click_link "List"
      expect(current_path).to eq(tracks_path)
      expect(page).to have_content("Test Software")
      expect(page).to have_content("TS")
      expect(page).to have_content("42")
    end

    scenario "Name, code and AEiC fields are mandatory" do
      visit new_track_path

      fill_in :track_short_name, with: "TS"
      fill_in :track_code, with: "42"
      check "Testeditor In-chief"
      click_on "Create Track"
      expect(page).to have_content("Track could not be saved.")
      expect(page).to have_content("Name: can't be blank")

      fill_in :track_name, with: "Test Software"
      fill_in :track_short_name, with: "TS"
      fill_in :track_code, with: ""
      check "Testeditor In-chief"
      click_on "Create Track"
      expect(page).to have_content("Track could not be saved.")
      expect(page).to have_content("Code: is not a number")

      fill_in :track_name, with: "Test Software"
      fill_in :track_short_name, with: "TS"
      fill_in :track_code, with: "42"
      uncheck "Testeditor In-chief"
      click_on "Create Track"
      expect(page).to have_content("Track could not be saved.")
      expect(page).to have_content("Each track must have at least one Associate Editor in Chief")
    end

    feature "Deleting a track" do
      before do
        @other_track = create(:track, name: "New track", short_name: "NT", code: "7", aeic_ids: [@aeic.id])
        @editor = create(:editor, first_name: "Testtopic", last_name: "Editorperson", track_ids: [@track.id, @other_track.id])
        @pending_paper = create(:submitted_paper, track: @track)
        @submitted_paper = create(:accepted_paper, track: @track)
        @subject_A = create(:subject, name: "Tester subsubject", track_id: @track.id)
        @subject_B = create(:subject, name: "Solar Astronomy")
      end

      scenario "Show papers, editors and subjects assigned to the track" do
        within("#track_#{@track.id}") {
          click_link "Edit"
        }
        click_link "Reassign papers and Delete"

        expect(current_path).to eq(remove_track_path(@track))
        expect(page).to have_content("Papers in this track: In-progress: 1, Total: 2")
        expect(page).to have_content("Your are going to delete the track: Testing track")
        expect(page).to have_content("Removing Track: 33 (TE)")
        expect(page).to have_content("Testtopic Editorperson")
        expect(page).to have_content("Tester subsubject")
        expect(page).to_not have_content("Solar Astronomy")
      end

      scenario "A new track must be specified for assigned papers" do
        visit remove_track_path(@track)
        click_on "Reassign papers and Delete track"

        expect(page).to have_content("Track could not be deleted.")
        expect(page).to have_content("You must provide a track to assign all papers from this track before deleting it.")
      end

      scenario "Papers are reassigned and track destroyed" do
        tracks_before = Track.count
        subjects_before = Subject.count

        visit remove_track_path(@track)
        select "New track", from: "new_track_id"
        click_on "Reassign papers and Delete track"

        expect(page).to have_content("Track was successfully destroyed.")
        expect(current_path).to eq(tracks_path)
        expect(page).to_not have_content("Testing track")
        expect(page).to have_content("New track")

        expect(@pending_paper.reload.track).to eq(@other_track)
        expect(@submitted_paper.reload.track).to eq(@other_track)

        expect(@editor.reload.tracks.size).to eq(1)
        expect(@editor.tracks.first).to eq(@other_track)

        expect(@aeic.reload.managed_tracks.size).to eq(1)
        expect(@aeic.managed_tracks.first).to eq(@other_track)

        tracks_after = Track.count
        subjects_after = Subject.count

        expect(tracks_before - tracks_after).to eq(1)
        expect(subjects_before - subjects_after).to eq(1)
      end
    end
  end
end
