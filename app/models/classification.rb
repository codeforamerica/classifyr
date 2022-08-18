class Classification < ApplicationRecord
  has_paper_trail

  CALL_TYPE = "Detailed Call Type".freeze

  belongs_to :common_incident_type, optional: true
  belongs_to :user, optional: true
  belongs_to :unique_value, optional: true, counter_cache: true

  after_save :update_data_set_completion

  enum :confidence_rating, {
    "Low Confidence" => 0,
    "Somewhat Confident" => 1,
    "Very Confident" => 2,
  }

  validates :user, :unique_value, :common_type, :value,
            presence: true

  def confidence_rating=(rating)
    rating = rating.to_i if rating.is_a?(String)
    super(rating)
  end

  private

  def update_data_set_completion
    return true unless unique_value

    unique_value.field.data_set.update_completion
  end
end
