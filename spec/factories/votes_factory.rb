FactoryBot.define do
  factory :vote do
    factory :out_of_scope_vote do
      kind { "out-of-scope"}
      comment { "Out of scope because reasons" }
    end

    factory :in_scope_vote do
      kind { "in-scope"}
      comment { "In scope because reasons" }
    end
  end 
end
