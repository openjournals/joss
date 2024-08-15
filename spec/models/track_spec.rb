# == Schema Information
#
# Table name: tracks
#
#  id         :bigint           not null, primary key
#  code       :integer
#  name       :string
#  short_name :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tracks_on_name  (name)
#
require 'rails_helper'

RSpec.describe Track, type: :model do

  describe "#associations" do
    it "has many papers" do
      association = Track.reflect_on_association(:papers)
      expect(association.macro).to eq(:has_many)
    end

    it "has and belong to many editors" do
      association = Track.reflect_on_association(:editors)
      expect(association.macro).to eq(:has_and_belongs_to_many)
    end

    it "has many track_aeics" do
      association = Track.reflect_on_association(:track_aeics)
      expect(association.macro).to eq(:has_many)
    end

    it "has many aeics" do
      association = Track.reflect_on_association(:aeics)
      expect(association.macro).to eq(:has_many)
    end

    it "has many subjects" do
      association = Track.reflect_on_association(:subjects)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe "#full_name" do
    it "includes code and name" do
      track = create(:track, code: 33, name: "Earth sciences and Ecology", short_name: "ESE")

      expect(track.full_name).to eq "33 Earth sciences and Ecology"
    end
  end

  describe "#label" do
    it "includes code and short name" do
      track = create(:track, code: 33, name: "Earth sciences and Ecology", short_name: "ESE")

      expect(track.label).to eq "Track: 33 (ESE)"
    end
  end


  describe "#aeic_emails" do
    it "returns an array of aeic emails" do
      editor_1 = create(:board_editor, :email => "editor_1@example.com")
      editor_2 = create(:board_editor, :email => "editor_2@example.com")
      track = create(:track, :aeics => [editor_1, editor_2])

      expect(track.aeic_emails).to eq ["editor_1@example.com", "editor_2@example.com"]
    end
  end
  
  describe "#name_with_short_name" do
    it "includes name and short name" do
      track = create(:track, code: 33, name: "Earth sciences and Ecology", short_name: "ESE")

      expect(track.name_with_short_name).to eq "Earth sciences and Ecology (ESE)"
    end
  end

  describe "#parameterized_short_name" do
    it "returns parameterized short name" do
      track = create(:track, code: 33, name: "Earth sciences and Ecology", short_name: "Earth S.E")

      expect(track.parameterized_short_name).to eq "earth-s-e"
    end
  end
end
