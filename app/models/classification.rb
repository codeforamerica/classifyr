class Classification < ApplicationRecord
  has_paper_trail

  CALL_TYPE = "Detailed Call Type".freeze
  LOW_CONFIDENCE = "Low Confidence".freeze
  SOMEWHAT_CONFIDENT = "Somewhat Confident".freeze
  VERY_CONFIDENT = "Very Confident".freeze

  belongs_to :common_incident_type, optional: true
  belongs_to :user, optional: true
  belongs_to :unique_value, optional: true, counter_cache: true

  after_save :update_data_set_completion_and_approval_status

  enum :confidence_rating, {
    LOW_CONFIDENCE => 0,
    SOMEWHAT_CONFIDENT => 1,
    VERY_CONFIDENT => 2,
  }

  validates :user, :unique_value, :common_type, :value,
            presence: true

  def confidence_rating=(rating)
    rating = rating.to_i if rating.is_a?(String)
    super(rating)
  end

  private

  def update_data_set_completion_and_approval_status
    return true unless unique_value

    unique_value.field.data_set.update_completion
    unique_value.update_approval_status

    true
  end
end
