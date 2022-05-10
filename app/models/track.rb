class Track < ApplicationRecord
  has_many :papers
  has_and_belongs_to_many :editors

  def full_name
    [code.to_s, name].join(" ")
  end
end
