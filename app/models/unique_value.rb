# frozen_string_literal: true

# Represents a unique value for a single dataset field.
class UniqueValue < ApplicationRecord
  COMPLETION_COUNT = 3
  EXAMPLE_COUNT = 5
  MIN_APPROVAL_CONFIDENCE = Classification::SOMEWHAT_CONFIDENT

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged]

  has_paper_trail

  belongs_to :field
  has_one :data_set, through: :field
  has_many :classifications, dependent: :nullify
  has_many :users, through: :classifications

  scope :to_classify_with_data_set_priority, lambda { |user|
    joins(:data_set)
      .order('data_sets.completion_percent ASC, unique_values.classifications_count ASC')
      .call_types.not_completed.not_classified_by(user)
  }
  scope :to_classify, lambda { |user|
    ordered_by_completion.not_completed.not_classified_by(user)
  }
  scope :call_types, -> { joins(:field).where(field: { common_type: Classification::CALL_TYPE }) }
  scope :ordered_by_completion, -> { order(frequency: :desc, classifications_count: :asc) }
  scope :not_completed, -> { where('classifications_count < ?', COMPLETION_COUNT) }
  scope :classified_by, lambda { |user|
    left_joins(:classifications).where(classifications: { user_id: user.id })
  }
  scope :not_classified_by, lambda { |user|
    where.not(id: classified_by(user))
  }

  def classification_by(user)
    classifications.where(user_id: user.id).first
  end

  def classification
    return @classification if @classification

    threshold = Classification.confidence_ratings[MIN_APPROVAL_CONFIDENCE]
    classification = classifications.where(confidence_rating: threshold..)
                                    .joins(:common_incident_type)
                                    .group('common_incident_types.code')
                                    .order(count: :desc).count.first

    @classification = {
      value: classification&.[](0),
      count: classification&.[](1) || 0
    }
  end

  def update_approval_status
    return if classifications_count < COMPLETION_COUNT

    if can_auto_approve?
      update(approved_at: Time.now.utc)
    else
      update(review_required: true, auto_reviewed_at: Time.now.utc)
    end
  end

  def find_or_generate_examples
    return examples if examples.present?

    new_examples = generate_examples
    update(examples: new_examples)
    new_examples
  end

  def generate_examples
    data = []

    field.data_set.datafile.with_file do |f|
      CSV.foreach(f, headers: true) do |row|
        data << row.values_at if row[field.heading] == value
        break if data.length >= EXAMPLE_COUNT
      end
    end

    data
  end

  private

  def can_auto_approve?
    confident_enough = true
    incident_type_ids = classifications.map do |classification|
      ratings = Classification.confidence_ratings
      if classification.confidence_rating.blank? ||
         (ratings[classification.confidence_rating] < ratings[MIN_APPROVAL_CONFIDENCE])
        confident_enough = false
      end

      classification.common_incident_type_id
    end

    # A single incident type for all classifications
    incident_type_ids.uniq.length == 1 && confident_enough
  end

  def slug_candidates
    return [:value] unless data_set

    ["#{data_set.slug}-#{value}"]
  end
end
