RSpec.describe ReviewersApi do

  before(:each) do
    allow(Faraday).to receive(:post).and_return(double(status: 500))
  end

  describe ".api_configured?" do
    it "is true if Reviewers API ENV vars have value" do
      ENV['REVIEWERS_HOST_URL'] = "https://reviewers-api.test"
      ENV['REVIEWERS_API_TOKEN'] = "testTOKEN"

      expect(ReviewersApi.api_configured?).to eq(true)
    end

    it "is false if Reviewers API ENV vars are empty" do
      ENV['REVIEWERS_HOST_URL'] = ""
      ENV['REVIEWERS_API_TOKEN'] = ""
      expect(ReviewersApi.api_configured?).to eq(false)

      ENV['REVIEWERS_HOST_URL'] = nil
      ENV['REVIEWERS_API_TOKEN'] = nil
      expect(ReviewersApi.api_configured?).to eq(false)
    end
  end

  describe "When API is not configured" do
    before do
      expect(ReviewersApi).to receive(:api_configured?).and_return(false)
    end

    it ".assign_reviewer returns false" do
      expect(ReviewersApi.assign_reviewer("reviewer21", 1234)).to eq(false)
    end

    it ".assign_reviewers returns false" do
      expect(ReviewersApi.assign_reviewers("reviewer21", 1234)).to eq(false)
    end

    it ".unassign_reviewer returns false" do
      expect(ReviewersApi.unassign_reviewer("reviewer21", 1234)).to eq(false)
    end

    it ".unassign_reviewers returns false" do
      expect(ReviewersApi.unassign_reviewers("reviewer21", 1234)).to eq(false)
    end
  end

  describe "When API is configured" do
    before do
      allow(ReviewersApi).to receive(:api_configured?).and_return(true)
      ENV['REVIEWERS_HOST_URL'] = "https://reviewers-api.test"
      ENV['REVIEWERS_API_TOKEN'] = "testTOKEN"
    end

    describe ".assign_reviewer" do
      it "calls the Reviewers API assigning reviewer to issue" do
        expected_url = "https://reviewers-api.test/api/stats/update/reviewer21/review_assigned"
        expected_params = { idempotency_key: "assign-reviewer21-1234" }
        expected_headers = { "TOKEN" => "testTOKEN" }

        expect(Faraday).to receive(:post).with(expected_url, expected_params, expected_headers)

        ReviewersApi.assign_reviewer("reviewer21", 1234)
      end

      it "returns whether or not response is 2XX" do
        expect(Faraday).to receive(:post).and_return(double(status: 200))
        expect(ReviewersApi.assign_reviewer("reviewer21", 1234)).to eq(true)

        expect(Faraday).to receive(:post).and_return(double(status: 404))
        expect(ReviewersApi.assign_reviewer("reviewer33", 5678)).to eq(false)
      end

      it "logs API call errors" do
        expect(Faraday).to receive(:post).and_return(double(status: 403))
        expect(Rails.logger).to receive(:warn).with("Error assigning review 1234 to reviewer21: Got response code 403")

        ReviewersApi.assign_reviewer("reviewer21", 1234)
      end
    end

    describe ".unassign_reviewer" do
      it "calls the Reviewers API unassigning reviewer from issue" do
        expected_url = "https://reviewers-api.test/api/stats/update/reviewer21/review_unassigned"
        expected_params = { idempotency_key: "unassign-reviewer21-1234" }
        expected_headers = { "TOKEN" => "testTOKEN" }

        expect(Faraday).to receive(:post).with(expected_url, expected_params, expected_headers)

        ReviewersApi.unassign_reviewer("reviewer21", 1234)
      end

      it "returns whether or not response is 2XX" do
        expect(Faraday).to receive(:post).and_return(double(status: 200))
        expect(ReviewersApi.unassign_reviewer("reviewer21", 1234)).to eq(true)

        expect(Faraday).to receive(:post).and_return(double(status: 404))
        expect(ReviewersApi.unassign_reviewer("reviewer33", 5678)).to eq(false)
      end

      it "logs API call errors" do
        expect(Faraday).to receive(:post).and_return(double(status: 403))
        expect(Rails.logger).to receive(:warn).with("Error unassigning reviewer21 from review 1234: Got response code 403")

        ReviewersApi.unassign_reviewer("reviewer21", 1234)
      end
    end

    describe ".assign_reviewers" do
      it "calls ReviewersApi.assign_reviewer for each reviewer" do
        expect(ReviewersApi).to receive(:assign_reviewer).once.with("reviewer21", 1234)
        expect(ReviewersApi).to receive(:assign_reviewer).once.with("reviewer33", 1234)
        expect(ReviewersApi).to receive(:assign_reviewer).once.with("reviewer42", 1234)

        ReviewersApi.assign_reviewers(["reviewer21", "reviewer33", "reviewer42"], 1234)
      end

      it "can parse string of reviewers into an array" do
        expect(ReviewersApi).to receive(:assign_reviewer).once.with("reviewer21", 1234)
        expect(ReviewersApi).to receive(:assign_reviewer).once.with("reviewer33", 1234)
        expect(ReviewersApi).to receive(:assign_reviewer).once.with("reviewer42", 1234)

        ReviewersApi.assign_reviewers("reviewer21, reviewer33, reviewer42", 1234)
      end
    end

    describe ".unassign_reviewers" do
      it "calls ReviewersApi.unassign_reviewer for each reviewer" do
        expect(ReviewersApi).to receive(:unassign_reviewer).once.with("reviewer21", 1234)
        expect(ReviewersApi).to receive(:unassign_reviewer).once.with("reviewer33", 1234)
        expect(ReviewersApi).to receive(:unassign_reviewer).once.with("reviewer42", 1234)

        ReviewersApi.unassign_reviewers(["reviewer21", "reviewer33", "reviewer42"], 1234)
      end

      it "can parse string of reviewers into an array" do
        expect(ReviewersApi).to receive(:unassign_reviewer).once.with("reviewer21", 1234)
        expect(ReviewersApi).to receive(:unassign_reviewer).once.with("reviewer33", 1234)
        expect(ReviewersApi).to receive(:unassign_reviewer).once.with("reviewer42", 1234)

        ReviewersApi.unassign_reviewers("reviewer21, reviewer33, reviewer42", 1234)
      end
    end


  end

end