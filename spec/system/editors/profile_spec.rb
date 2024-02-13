require "rails_helper"

feature "Editor profile" do
  let(:user_editor) { create(:user, editor: create(:editor, first_name: 'Lorena', description: 'Science testing editor')) }

  scenario "Is not public" do
    visit editor_profile_path
    expect(page).to have_content('Please login first')
  end

  scenario "Is not available to non-editor users" do
    login_as(create(:user))
    visit editor_profile_path
    expect(page).to have_content('You are not permitted to view that page')

    click_on 'My Profile'
    expect(page).to_not have_content('Editor profile')
  end

  scenario "Show editor's data, including tracks if tracks are enabled" do
    enable_feature(:tracks) do
      login_as(user_editor)
      visit root_path
      click_on 'My Profile'
      click_on 'Editor profile'
      expect(page.status_code).to eq(200)

      first_name = find_field('First name').value
      description = find_field('Description').value

      expect(first_name).to eq('Lorena')
      expect(description).to eq('Science testing editor')

      expect(user_editor.editor.track_ids.size > 0).to be true
      expect(page).to have_content("Tracks")
      user_editor.editor.track_ids.each do |track_id|
        expect(page).to have_checked_field("editor_track_ids_#{track_id}")
      end
    end
  end

  scenario "Show editor's data, without tracks if tracks are disabled" do
    disable_feature(:tracks) do
      login_as(user_editor)
      visit root_path
      click_on 'My Profile'
      click_on 'Editor profile'
      expect(page.status_code).to eq(200)

      first_name = find_field('First name').value
      description = find_field('Description').value

      expect(first_name).to eq('Lorena')
      expect(description).to eq('Science testing editor')

      expect(user_editor.editor.track_ids.size == 0).to be true
      expect(page).to_not have_content("Tracks")
    end
  end

  scenario "Update editor's data" do
    login_as(user_editor)
    visit editor_profile_path
    fill_in 'First name', with: 'Kristina'
    fill_in 'Description', with: 'Open Science editor'
    click_on 'Update editor profile'

    visit root_path
    click_on 'My Profile'
    click_on 'Editor profile'

    first_name = find_field('First name').value
    description = find_field('Description').value

    expect(first_name).to eq('Kristina')
    expect(description).to eq('Open Science editor')
  end
end