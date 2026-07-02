require "rails_helper"

feature "About page" do
  scenario "editorial board members' titles include their managed tracks" do
    aeic = create(:board_editor)
    create(:track, name: "Track One", aeics: [aeic])
    create(:track, name: "Track Two", aeics: [aeic])

    visit about_path

    expect(page).to have_content("Associate Editor-in-Chief: Track One; Track Two")
  end

  scenario "editorial board members with no managed tracks show their title" do
    create(:board_editor, title: "Editor-in-Chief")

    visit about_path

    expect(page).to have_content("Editor-in-Chief")
  end
end
