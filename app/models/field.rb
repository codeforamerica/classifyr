class Field < ApplicationRecord
  has_paper_trail

  belongs_to :data_set
  has_many :unique_values, dependent: :destroy

  TYPES = [
    "", "Emergency Category", "Call Category", Classification::CALL_TYPE,
    "-----------------", "Call Identifier", "Call Time", "Call Disposition", "Priority", "Dispatched Unit Type",
    "-----------------", "Geolocation Latitude", "Geolocation Longitude",
    "-----------------", "Flag Alcohol Related", "Flag Domestic Violence", "Flag Drug Related", "Flag Mental Health"
  ].freeze

  # FORMATS = ['', 'Lookup', 'Date', 'Time', 'Address', 'Geolocation', 'Text']
  #

  VALUE_TYPES = ["Emergency Category", "Call Category", Classification::CALL_TYPE, "Call Disposition",
                 "Priority"].freeze

  def self.mapped
    where("common_type IS NOT NULL AND common_type != ''")
  end

  def values?
    VALUE_TYPES.include? common_type
  end

  def self.with_values
    where(common_type: VALUE_TYPES)
  end

  def self.without_values
    where.not(common_type: VALUE_TYPES)
  end
end
