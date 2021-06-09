require "rails_helper"

feature "Dashboard" do
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
end