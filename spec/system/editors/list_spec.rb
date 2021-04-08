require "rails_helper"

feature "Editor list" do
  let(:user_editor) { create(:user, editor: create(:editor, first_name: 'Lorena', description: 'Science testing editor')) }
  let(:admin_editor) { create(:admin_user, editor: create(:board_editor)) }

  scenario "Is not public" do
    visit editors_path
    expect(page).to have_content('Please login first')
  end

  scenario "Is not available to non-eic users" do
    login_as(user_editor)
    visit editors_path
    expect(page).to have_content('You are not permitted to view that page')
  end

  scenario "Is visible to admins" do
    login_as(admin_editor)
    visit editors_path
    expect(page).to_not have_content('You are not permitted to view that page')
  end

  feature "Logged as an admin" do
    before do
      create(:editor, first_name: 'Tester',
                      login: 'tester',
                      description: 'Software testing editor',
                      categories: ['Computing', 'Test systems'],
                      availability_comment: 'Always available')
      login_as(admin_editor)
      visit editors_path
    end

    scenario "show the list of editors" do
      expect(page).to have_content('Computing, Test systems')
      expect(page).to have_content('2*')
    end

    scenario "editors info is editable" do
      allow(Repository).to receive(:editors).and_return(["@tester", "@mctester"])
      click_link "Edit", href: edit_editor_path(Editor.find_by(login: 'tester'))
      fill_in :editor_category_list, with: "Fancy"
      click_on "Update Editor"
      visit editors_path
      expect(page).to have_content('Fancy')
    end
  end
end
