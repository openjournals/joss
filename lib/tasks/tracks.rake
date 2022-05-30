require "yaml"

namespace :tracks do
  desc "Create a yaml file with the current tracks and subjects info"
  task current_info: :environment do
    tracks_info = {"tracks" => {}}

    tracks = Track.all.includes(:subjects, :aeics).order(code: :asc)
    tracks.each do |t|
      t_info = { name: t.name,
                 short_name: t.short_name,
                 code: t.code,
                 aeics: t.aeics.map(&:full_name),
                 fields: t.subjects.map(&:name)
               }.stringify_keys
      tracks_info["tracks"][t.name.parameterize] = t_info
    end

    File.open("tracks_current_info.yml", "w") do |f|
      f.write tracks_info.to_yaml
    end
  end

  desc "Import tracks and subjects from the lib/tracks.yml file"
  task import: :environment do
    tracks_info = YAML.load_file(Rails.root + "lib/tracks.yml")
    tracks_info["tracks"].each_pair do |k, v|
      track = Track.find_or_initialize_by(name: v["name"])
      track.code = v["code"]
      track.short_name = v["short_name"]
      track.save!

      v["fields"].each do |subject|
        s = Subject.find_or_initialize_by(name: subject)
        s.track_id = track.id
        s.save!
      end
    end
  end
end
