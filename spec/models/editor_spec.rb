require 'rails_helper'

RSpec.describe Editor, type: :model do
  let(:editor) { create(:editor) }

  describe "#category_list" do
    subject { create(:editor, categories: %w(a b c)).category_list }
    it { is_expected.to eql("a, b, c") }
  end

  describe "#category_list=" do
    let(:editor) { create(:editor, categories: []) }

    it "assigns #categories" do
      expect {
        editor.category_list = "a, b, c"
      }.to change {
        editor.categories
      }.from([]).to(%w(a b c))
    end
  end

  describe "#full_name" do
    subject { editor.full_name }
    it { is_expected.to eql "#{editor.first_name} #{editor.last_name}" }
  end

  context "switching type to topic" do
    before(:each) { editor.update_attributes(kind: "board", title: "chief") }

    it "clears the title" do
      expect {
        editor.update_attributes(kind: "topic")
      }.to change {
        editor.title
      }.from("chief").to(nil)
    end
  end

  describe "#format_login" do
    let(:editor) { build(:editor, login: "@somebody") }

    it "removes @'s" do
      expect { editor.save }.to change { editor.login }.to "somebody"
    end
  end

  describe "#active editors" do
    it "should exclude emeritus" do
      editor_1 = create(:editor, login: "@board1", :kind => "board")
      editor_2 = create(:editor, login: "@topic1", :kind => "topic")
      editor_3 = create(:editor, login: "@retired1", :kind => "emeritus")

      assert Editor.active.count == 2
      assert Editor.emeritus.count == 1
    end
  end
end
