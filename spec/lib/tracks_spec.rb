RSpec.describe do
  let(:reference_tracks) do
    YAML.load_file('spec/fixtures/reference-tracks.yml')
  end

  let(:joss_tracks) do 
    YAML.load_file('lib/tracks.yml')
  end

  describe "Reference tracks" do
    it "should be 346 in total" do
      expect(reference_tracks.size).to eq(346)
    end

    it "should be not have any dupes" do
      expect(reference_tracks.uniq.size).to eq(346)
    end
  end

  describe "JOSS tracks" do
    it "should have 8 top level tracks" do
      expect(joss_tracks['tracks'].size).to eq(8)
    end

    it "should have the right structure" do
      expected_values = ['name', 'short_name', 'eics', 'code', 'fields']
      joss_tracks['tracks'].each_pair do |track_slug, track_values|
        expect(track_values.keys).to eq(expected_values)
        expect(track_values['eics']).to be_a(Array)
        expect(track_values['fields']).to be_a(Array)
        expect(track_values['eics']).not_to be_empty
        expect(track_values['fields']).not_to be_empty
      end
    end

    it "should have no dupes" do
      all_tracks = joss_tracks['tracks'].collect {|k,v| v['fields']}.flatten.uniq

      expect(all_tracks.size).to eq(344)
    end

    it "should include all of the reference tracks" do
      all_tracks = joss_tracks['tracks'].collect {|k,v| v['fields']}.flatten.uniq

      reference_tracks.each do |track|
        expect(all_tracks.include?(track)).to be(true), "Track #{track} is missing"
      end
    end
  end
end
