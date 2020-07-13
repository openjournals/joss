FactoryBot.define do
  factory :vote do
    factory :out_of_scope_vote do
      kind { "out-of-scope"}
    end

    factory :in_scope_vote do
      kind { "in-scope"}
    end
  end 
end
