require 'rails_helper'

RSpec.describe TrackAeic, type: :model do

  describe "associations" do
    it "belongs to an editor" do
      association = TrackAeic.reflect_on_association(:editor)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to a track" do
      association = TrackAeic.reflect_on_association(:track)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    before do
      @track = create(:track, code: 33, name: "Earth sciences and Ecology", short_name: "ESE")
    end

    it "editor assigned to each track only once" do
      @aeic = create(:board_editor)

      @track.aeics << @aeic
      assignment = TrackAeic.new(editor: @aeic, track: @track)

      expect(assignment).to_not be_valid
      expect(assignment.errors.full_messages).to eq(["Editor has already been taken"])
    end

    it "editor must be AEiC" do
      topic_editor = create(:editor)
      assignment = TrackAeic.new(editor: topic_editor, track: @track)

      expect(topic_editor).to_not be_board
      expect(assignment).to_not be_valid
      expect(assignment.errors.full_messages).to eq(["Editor is not an AEiC"])
    end
  end
end
