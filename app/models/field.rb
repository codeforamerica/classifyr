class Field < ApplicationRecord
  has_paper_trail

  belongs_to :data_set
  has_many :unique_values, dependent: :destroy
  has_many :classifications, through: :unique_values

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

  scope :classified, -> { joins(:classifications).distinct }
  scope :not_classified, -> { where.missing(:classifications).distinct }
  scope :mapped, -> { where("fields.common_type IS NOT NULL AND fields.common_type != ''") }
  scope :with_values, -> { where(common_type: VALUE_TYPES) }
  scope :without_values, -> { where.not(common_type: VALUE_TYPES) }

  def classified?
    classifications.any?
  end

  def values?
    VALUE_TYPES.include? common_type
  end

  def map_to(new_common_type)
    new_common_type = nil if new_common_type.blank?

    # If the field is classified or its common_type wasn't changed,
    # we skip
    return if classified? || common_type == new_common_type

    # If the new common_type is not of interest, we delete the
    # unique values.
    unless Field::VALUE_TYPES.include?(new_common_type)
      unique_values.destroy_all
    end

    update(common_type: new_common_type)
  end

  def pick_value_to_classify_for(user)
    return nil unless unique_values.any?

    unique_values.to_classify(user).first
  end
end
