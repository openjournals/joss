require 'rails_helper'

RSpec.describe Subject, type: :model do

  describe "associations" do
    it "belongs to a track" do
      association = Subject.reflect_on_association(:track)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    it "name must be unique" do
      subject1 = Subject.create(name: "Machine Learning", track: create(:track))
      subject2 = Subject.new(name: "Machine Learning", track: create(:track))

      expect(subject2).to_not be_valid
      expect(subject2.errors.full_messages).to eq(["Name has already been taken"])
    end

    it "name must be present" do
      subject = Subject.new(track: create(:track))

      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(["Name can't be blank"])
    end

    it "subject must belong to a track" do
      subject = Subject.new(name: "Machine Learning")

      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(["Track must exist"])
    end
  end
end
