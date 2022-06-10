require 'rails_helper'

RSpec.describe "editors/edit", type: :view do
  before(:each) do
    @editor = assign(:editor, create(:editor))
    allow(Repository).to receive(:editors).and_return %w(@user1 @user2 @user3)
  end

  it "renders the edit editor form" do
    render

    assert_select "form[action=?][method=?]", editor_path(@editor), "post" do
      assert_select "select#editor_kind[name=?]", "editor[kind]"
      assert_select "input#editor_max_assignments[name=?]", "editor[max_assignments]"
      assert_select "input#editor_availability_comment[name=?]", "editor[availability_comment]"
      assert_select "input#editor_title[name=?]", "editor[title]"
      assert_select "input#editor_first_name[name=?]", "editor[first_name]"
      assert_select "input#editor_last_name[name=?]", "editor[last_name]"
      assert_select "select#editor_login[name=?]", "editor[login]"
      assert_select "input#editor_email[name=?]", "editor[email]"
      assert_select "input#editor_avatar_url[name=?]", "editor[avatar_url]"
      assert_select "input#editor_category_list[name=?]", "editor[category_list]"
      assert_select "input#editor_url[name=?]", "editor[url]"
      assert_select "input[name=?]", "editor[track_ids][]"
      assert_select "textarea#editor_description[name=?]", "editor[description]"
    end
  end
end
