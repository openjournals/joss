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
end
