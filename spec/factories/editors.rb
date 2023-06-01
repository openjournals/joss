FactoryBot.define do
  factory :editor do
    kind { "topic" }
    first_name { "Person" }
    last_name { "McEditor" }
    sequence(:login) {|n| "mceditor_#{n}" }
    email { "mceditor@example.com" }
    avatar_url { "http://placekitten.com/g/200" }
    categories { %w(topic1 topic2 topic3) }
    url { "http://placekitten.com" }
    description { "Person McEditor is an editor" }
    availability_comment { "OOO until March 1" }
    track_ids { (["board", "emeritus"].include?(kind) ? [] : [create(:track).id]) if JournalFeatures.tracks? }

    factory :board_editor do
      kind { "board" }
      track_ids {[]}
    end

    factory :emeritus_editor do
      kind { "emeritus" }
      track_ids {[]}
    end

    factory :pending_editor do
      kind { "pending" }
    end
  end
end
