class Track < ApplicationRecord
  has_many :papers
  has_many :subjects, inverse_of: :track
  has_and_belongs_to_many :editors
  has_many :track_aeics, dependent: :destroy
  has_many :aeics, through: :track_aeics, source: :editor

  validates_uniqueness_of :code

  def full_name
    [code.to_s, name].join(" ")
  end

  def label
    "Track: #{code} (#{name})"
  end
end
