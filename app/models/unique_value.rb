class UniqueValue < ApplicationRecord
  COMPLETION_COUNT = 3

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

  def examples
    data = []
    field.data_set.datafile.with_file do |f|
      data = `tail -n +2 #{f.path} | grep "#{value}" | head -5`&.split("\n")&.map do |line|
        line.split(",")
      end
    end

    data
  end
end
