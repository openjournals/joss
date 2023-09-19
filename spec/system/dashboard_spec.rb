require "rails_helper"

feature "Dashboard" do
  before { skip_paper_repo_url_check }
  let(:dashboard_paths) {[dashboard_all_path, dashboard_incoming_path, dashboard_in_progress_path, dashboard_path]}
  let(:user_editor) { create(:user, editor: create(:editor)) }

  scenario "Is not public" do
    dashboard_paths.each do |dashboard_path|
      visit dashboard_path
      expect(page).to have_content("Please login first")
    end
  end

  scenario "Is not available to non-editor users" do
    login_as(create(:user))
    dashboard_paths.each do |dashboard_path|
      visit dashboard_path
      expect(page).to have_content("You are not permitted to view that page")
    end
  end

  scenario "Is visible to editors" do
    login_as(user_editor)

    visit root_path
    expect(page).to have_link "Dashboard"

    dashboard_paths.each do |dashboard_path|
      visit dashboard_path
      expect(page).to_not have_content("You are not permitted to view that page")
      expect(page).to have_content("Welcome, #{user_editor.editor.full_name}")
    end
  end

  scenario "Link is not visible to pending editors" do
    login_as(create(:user, editor: create(:pending_editor)))
    visit root_path

    expect(page).to_not have_link "Dashboard"
  end

  feature "Tabs" do
    before do
      editor = create(:editor, login: "editor1")
      @track = create(:track, name: "TestingTrack")
      query_scoped_paper = create(:paper, state: "submitted", title: "Paper Submitted", labels:{"query-scope" => "C0C"}, editor: nil)
      create(:in_scope_vote, editor: editor, paper: query_scoped_paper)
      create(:paper, state: "under_review", title: "Paper Under Review", editor: editor)
      create(:paper, state: "review_pending", title: "Paper Review Pending No Editor", labels:{"query-scope" => "C0C"}, editor: nil, track: @track)
      create(:paper, state: "review_pending", title: "Paper Review Pending With Editor", editor: editor, track: @track)
      create(:accepted_paper, title: "Paper Accepted", editor: editor, track: @track)
      create(:rejected_paper, title: "Paper Rejected")
      login_as(user_editor)
      visit dashboard_path
    end

    scenario "List papers with no editor" do
      click_link "Papers with no editor"
      expect(page).to have_content("Paper Submitted")
      expect(page).to have_content("Paper Review Pending No Editor")
      expect(page).to_not have_content("Paper Under Review")
      expect(page).to_not have_content("Paper Review Pending With Editor")
      expect(page).to_not have_content("Paper Accepted")
      expect(page).to_not have_content("Paper Rejected")
    end

    scenario "List in progress papers" do
      click_link "In progress papers"
      expect(page).to have_content("Paper Submitted")
      expect(page).to have_content("Paper Review Pending No Editor")
      expect(page).to have_content("Paper Under Review")
      expect(page).to have_content("Paper Review Pending With Editor")
      expect(page).to_not have_content("Paper Accepted")
      expect(page).to_not have_content("Paper Rejected")
    end

    scenario "List query scoped papers" do
      click_link "👍👎"
      expect(page).to have_content("Paper Submitted")
      expect(page).to have_content("Paper Review Pending No Editor")
      expect(page).to_not have_content("Paper Under Review")
      expect(page).to_not have_content("Paper Review Pending With Editor")
      expect(page).to_not have_content("Paper Accepted")
      expect(page).to_not have_content("Paper Rejected")
    end

    scenario "List all visible papers" do
      click_link "All papers"
      expect(page).to have_content("Paper Submitted")
      expect(page).to have_content("Paper Review Pending No Editor")
      expect(page).to have_content("Paper Under Review")
      expect(page).to have_content("Paper Review Pending With Editor")
      expect(page).to have_content("Paper Accepted")
      expect(page).to have_content("Paper Rejected")
    end

    scenario "Dropdown is not visible if tracks are disabled" do
      disable_feature(:tracks) do
        expect(page).to_not have_css("select#track_id")

        visit dashboard_incoming_path
        expect(page).to_not have_css("select#track_id")

        visit "/dashboard/#{Editor.last.login}"
        expect(page).to_not have_css("select#track_id")

        visit dashboard_in_progress_path
        expect(page).to_not have_css("select#track_id")

        visit "/dashboard"
        expect(page).to_not have_css("select#track_id")

        visit dashboard_all_path
        expect(page).to_not have_css("select#track_id")
      end
    end

    feature "Filter by track, if tracks are enabled" do
      around(:example) do |ex|
        enable_feature(:tracks) do
          ex.run
        end
      end

      scenario "Dropdown is visible only in incoming/in_progress/query_scoped/all_papers tabs" do
        expect(page).to_not have_css("select#track_id")

        visit dashboard_incoming_path
        expect(page).to have_css("select#track_id")

        visit "/dashboard/#{Editor.last.login}"
        expect(page).to_not have_css("select#track_id")

        visit dashboard_in_progress_path
        expect(page).to have_css("select#track_id")

        visit dashboard_query_scoped_path
        expect(page).to have_css("select#track_id")

        visit "/dashboard"
        expect(page).to_not have_css("select#track_id")

        visit dashboard_all_path
        expect(page).to have_css("select#track_id")
      end

      scenario "Show only papers with selected track" do
        visit dashboard_incoming_path(track_id: @track.id)

        expect(page).to_not have_content("Paper Submitted")
        expect(page).to have_content("Paper Review Pending No Editor")
        expect(page).to_not have_content("Paper Under Review")
        expect(page).to_not have_content("Paper Review Pending With Editor")
        expect(page).to_not have_content("Paper Accepted")
        expect(page).to_not have_content("Paper Rejected")

        visit dashboard_in_progress_path(track_id: @track.id)

        expect(page).to_not have_content("Paper Submitted")
        expect(page).to have_content("Paper Review Pending No Editor")
        expect(page).to_not have_content("Paper Under Review")
        expect(page).to have_content("Paper Review Pending With Editor")
        expect(page).to_not have_content("Paper Accepted")
        expect(page).to_not have_content("Paper Rejected")

        visit dashboard_query_scoped_path(track_id: @track.id)

        expect(page).to_not have_content("Paper Submitted")
        expect(page).to have_content("Paper Review Pending No Editor")
        expect(page).to_not have_content("Paper Under Review")
        expect(page).to_not have_content("Paper Review Pending With Editor")
        expect(page).to_not have_content("Paper Accepted")
        expect(page).to_not have_content("Paper Rejected")


        visit dashboard_all_path(track_id: @track.id)

        expect(page).to_not have_content("Paper Submitted")
        expect(page).to have_content("Paper Review Pending No Editor")
        expect(page).to_not have_content("Paper Under Review")
        expect(page).to have_content("Paper Review Pending With Editor")
        expect(page).to have_content("Paper Accepted")
        expect(page).to_not have_content("Paper Rejected")
      end
    end
  end
end