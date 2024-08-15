# == Schema Information
#
# Table name: invitations
#
#  id         :bigint           not null, primary key
#  state      :string           default("pending")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  editor_id  :bigint
#  paper_id   :bigint
#
# Indexes
#
#  index_invitations_on_created_at  (created_at)
#  index_invitations_on_editor_id   (editor_id)
#  index_invitations_on_paper_id    (paper_id)
#  index_invitations_on_state       (state)
#
FactoryBot.define do
  factory :invitation do
    paper { create(:paper) }
    editor { create(:editor) }

    trait :pending do
      state { 'pending' }
    end

    trait :accepted do
      state { 'accepted' }
    end

    trait :expired do
      state { 'expired' }
    end
  end
end
