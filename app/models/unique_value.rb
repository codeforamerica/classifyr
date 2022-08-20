class UniqueValue < ApplicationRecord
  COMPLETION_COUNT = 3
  MIN_APPROVAL_CONFIDENCE = Classification::SOMEWHAT_CONFIDENT

  has_paper_trail

  belongs_to :field
  has_one :data_set, through: :field
  has_many :classifications, dependent: :nullify
  has_many :users, through: :classifications

  scope :to_classify_with_data_set_priority, lambda { |user|
    joins(:data_set)
      .order("data_sets.completion_percent ASC, unique_values.classifications_count ASC")
      .call_types.not_completed.not_classified_by(user)
  }
  scope :to_classify, lambda { |user|
    ordered_by_completion.not_completed.not_classified_by(user)
  }
  scope :call_types, -> { joins(:field).where(field: { common_type: Classification::CALL_TYPE }) }
  scope :ordered_by_completion, -> { order(frequency: :desc, classifications_count: :asc) }
  scope :not_completed, -> { where("classifications_count < ?", COMPLETION_COUNT) }
  scope :classified_by, lambda { |user|
    left_joins(:classifications).where(classifications: { user_id: user.id })
  }
  scope :not_classified_by, lambda { |user|
    where.not(id: classified_by(user))
  }

  def update_approval_status
    return if classifications_count < COMPLETION_COUNT

    if can_auto_approve?
      update(approved_at: Time.now.utc)
    else
      update(review_required: true, auto_reviewed_at: Time.now.utc)
    end
  end

  def examples
    data = []
    field.data_set.datafile.with_file do |f|
      data = `tail -n +2 #{f.path} | grep "#{value}" | head -5`&.split("\n")&.map do |line|
        line.split(",")
      end
    end

    data
  end

  private

  def can_auto_approve?
    confident_enough = true
    incident_type_ids = []

    classifications.each do |classification|
      incident_type_ids << classification.common_incident_type_id

      ratings = Classification.confidence_ratings
      if classification.confidence_rating.blank? ||
          (ratings[classification.confidence_rating] < ratings[MIN_APPROVAL_CONFIDENCE])
        confident_enough = false
      end
    end

    # A single incident type for all classifications
    incident_type_ids.uniq.length == 1 && confident_enough
  end
end
