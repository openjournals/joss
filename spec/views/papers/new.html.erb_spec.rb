require 'rails_helper'

RSpec.describe "papers/new", type: :view do
  let(:paper_types) { [] }
  let!(:paper) { assign(:paper, build(:paper)) }

  before(:each) do
    allow(Repository).to receive(:editors).and_return %w(@user1 @user2 @user3)
  end

  around(:each) do |example|
    setting = Rails.application.settings["paper_types"]
    Rails.application.settings["paper_types"] = paper_types
    example.run
    Rails.application.settings["paper_types"] = setting
  end

  context "with multiple paper types" do
    let(:paper_types) { %w(type1 type2 type3) }

    it "renders the new paper form" do
      render

      assert_select "form[action=?][method=?]", papers_path, "post" do
        assert_select "select#paper_kind[name=?]", "paper[kind]"
        assert_select "input#paper_title[name=?]", "paper[title]"
        assert_select "input#paper_repository_url[name=?]", "paper[repository_url]"
        assert_select "input#paper_software_version[name=?]", "paper[software_version]"
        assert_select "select#paper_suggested_editor[name=?]", "paper[suggested_editor]"
        assert_select "textarea#paper_body[name=?]", "paper[body]"
        assert_select "input#author-check"
        assert_select "input#coc-check"
      end
    end
  end

  context "with no paper types" do
    let(:paper_types) { [] }

    it "renders the new paper form" do
      render

      assert_select "form[action=?][method=?]", papers_path, "post" do
        assert_select "select#paper_kind", false
        assert_select "input#paper_title[name=?]", "paper[title]"
        assert_select "input#paper_repository_url[name=?]", "paper[repository_url]"
        assert_select "input#paper_software_version[name=?]", "paper[software_version]"
        assert_select "select#paper_suggested_editor[name=?]", "paper[suggested_editor]"
        assert_select "textarea#paper_body[name=?]", "paper[body]"
        assert_select "input#author-check"
        assert_select "input#coc-check"
      end
    end
  end
end
