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

  namespace :import do
    desc "Import subjects from the lib/tracks.yml file"
    task subjects: :environment do
      tracks_info = YAML.load_file(Rails.root + "lib/tracks.yml")
      tracks_info["tracks"].each_pair do |k, v|
        track = Track.find_by(name: v["name"].to_s.strip)
        if track.nil?
          puts "!! There is not a '#{v["name"]}' track. Please create it before importing the subjects."
        else
          track.subjects.delete_all

          v["fields"].each do |subject|
            s = Subject.find_or_initialize_by(name: subject)
            s.track_id = track.id
            s.save!
          end
          puts "- Track '#{v["name"]}': #{v['fields'].size} subjects imported"
        end
      end
    end

    desc "Print info on what tracks and subjects will be imported when running the import:subjects task"
    task dry_run: :environment do
      tracks_info = YAML.load_file(Rails.root + "lib/tracks.yml")
      tracks_info["tracks"].each_pair do |k, v|
        track = Track.find_by(name: v["name"].to_s.strip)
        if track.nil?
          puts "!! There is not a '#{v["name"]}' track. Please create it before importing the subjects."
        else
          puts "- Track '#{v["name"]}': #{v['fields'].size} subjects will be imported"
        end
      end
    end
  end
end
