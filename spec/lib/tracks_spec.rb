RSpec.describe do
  let(:joss_tracks) do
    YAML.load_file('lib/tracks.yml')
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
      all_fields = joss_tracks['tracks'].collect {|k,v| v['fields']}.flatten

      expect(all_fields.size).to eq(all_fields.uniq.size)
    end
  end
end
