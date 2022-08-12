class Subject < ApplicationRecord
  belongs_to :track, inverse_of: :subjects

  validates :name, uniqueness: true, presence: true
end
