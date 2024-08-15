# == Schema Information
#
# Table name: editors
#
#  id                   :integer          not null, primary key
#  availability_comment :string
#  avatar_url           :string
#  categories           :string           default([]), is an Array
#  description          :string           default("")
#  email                :string
#  first_name           :string           not null
#  kind                 :string           default("topic"), not null
#  last_name            :string           not null
#  login                :string           not null
#  max_assignments      :integer          default(4), not null
#  title                :string
#  url                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  buddy_id             :integer
#  user_id              :integer
#
# Indexes
#
#  index_editors_on_buddy_id  (buddy_id)
#  index_editors_on_user_id   (user_id)
#
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
