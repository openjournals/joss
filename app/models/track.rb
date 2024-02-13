class Track < ApplicationRecord
  has_many :papers
  has_many :subjects, inverse_of: :track, dependent: :destroy
  has_and_belongs_to_many :editors
  has_many :track_aeics, dependent: :destroy
  has_many :aeics, through: :track_aeics, source: :editor

  validates_presence_of :name
  validates_numericality_of :code, only_integer: true
  validates_uniqueness_of :code, scope: :short_name
  validates_presence_of :aeics, message: "Each track must have at least one Associate Editor in Chief"

  before_destroy { editors.clear }

  default_scope  { order(code: :asc) }

  def full_name
    [code.to_s, name].join(" ")
  end

  def label
    "Track: #{code} (#{short_name})"
  end

  def aeic_emails
    return [] if aeics.empty?
    aeics.collect { |e| e.email }
  end
  
  def name_with_short_name
    "#{name} (#{short_name})"
  end

  def label_color
    case short_name.downcase
    when "aass"
      "D4C5F9"
    when "bcm"
      "44D276"
    when "csism"
      "2B613B"
    when "dsais"
      "fc7484"
    when "ese"
      "FBCA04"
    when "misc"
      "5AD5D0"
    when "pe"
      "D07786"
    when "sbcs"
      "e374fc"
    else
      "E7E7E7"
    end
  end

  def parameterized_short_name
    short_name.gsub(/[^a-z0-9\-_]+/i, "-").downcase
  end
end
