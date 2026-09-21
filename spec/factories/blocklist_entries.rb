FactoryBot.define do
  factory :blocklist_entry do
    kind { "repository" }
    value { "github.com/spammer/repo" }
    reason { "Spam" }
    editor { create(:board_editor) }

    factory :blocked_orcid do
      kind { "orcid" }
      value { "0000-0000-0000-9999" }
    end
  end
end
