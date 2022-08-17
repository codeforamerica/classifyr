class UniqueValue < ApplicationRecord
  COMPLETION_COUNT = 3

  has_paper_trail

  belongs_to :field
  has_many :classifications, dependent: :nullify, counter_cache: true
  has_many :users, through: :classifications

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
