require 'rails_helper'

describe JournalFeatures do
  describe ".submissions_open?" do
    def with_env(value)
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("SUBMISSIONS_OPEN").and_return(value)
    end

    it "follows the settings file when SUBMISSIONS_OPEN is not set" do
      with_env(nil)
      enable_feature(:submissions_open) { expect(JournalFeatures.submissions_open?).to be true }
      disable_feature(:submissions_open) { expect(JournalFeatures.submissions_open?).to be false }
    end

    it "follows the settings file when SUBMISSIONS_OPEN is empty" do
      with_env(" ")
      disable_feature(:submissions_open) { expect(JournalFeatures.submissions_open?).to be false }
    end

    it "is open when the setting is absent" do
      with_env(nil)
      previous = Rails.application.settings[:features].delete(:submissions_open)
      begin
        expect(JournalFeatures.submissions_open?).to be true
      ensure
        Rails.application.settings[:features][:submissions_open] = previous
      end
    end

    it "opens submissions when SUBMISSIONS_OPEN=true, overriding the settings file" do
      with_env("true")
      disable_feature(:submissions_open) { expect(JournalFeatures.submissions_open?).to be true }
    end

    it "closes submissions when SUBMISSIONS_OPEN=false, overriding the settings file" do
      with_env("false")
      enable_feature(:submissions_open) { expect(JournalFeatures.submissions_open?).to be false }
    end
  end
end
