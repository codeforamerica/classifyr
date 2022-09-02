# rubocop:disable all
class DataSet < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  has_paper_trail

  has_many_attached :files, dependent: :destroy
  has_many :fields, dependent: :destroy

  validates :title, presence: true
  validates :files, attached: true

  attr_accessor :step

  scope :ordered, -> { order(created_at: :desc) }
  scope :to_classify, lambda {
    joins(:fields)
      .where(fields: { common_type: Classification::CALL_TYPE })
      .order(completion_percent: :asc, created_at: :asc)
  }

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  def call_type_field
    fields.where(common_type: Classification::CALL_TYPE).first
  end

  def pick_value_to_classify_for(user)
    call_type_field&.pick_value_to_classify_for(user)
  end

  def completed?
    completion_percent == 100
  end

  def storage_size
    files.sum(&:byte_size)
  end

  def row_count
    files.sum(&:row_count)
  end

  def datafile
    files.first
  end

  def emergency_categories
    fields.find_by(common_type: "Emergency Category").unique_values.order(:value)
  end

  def call_categories
    fields.find_by(common_type: "Call Category").unique_values.order(:value)
  end

  def detailed_call_types
    fields.find_by(common_type: Classification::CALL_TYPE).unique_values.order(:frequency)
  end

  def priorities
    fields.find_by(common_type: "Priority").unique_values.order(:value)
  end

  def start_time
    return unless (call_time = fields.find_by(common_type: "Call Time")&.min_value)

    Chronic.parse call_time.gsub(/[[:^ascii:]]/, "")
  end

  def end_time
    return unless (call_time = fields.find_by(common_type: "Call Time")&.max_value)

    Chronic.parse call_time.gsub(/[[:^ascii:]]/, "")
  end

  def timeframe(full: false)
    return unless start_time && end_time

    if full
      "#{start_time.to_date.to_fs(:display_date)} thru #{end_time.to_date.to_fs(:display_date)}"
    else
      "#{start_time.to_date.to_fs(:short_date)} - #{end_time.to_date.to_fs(:short_date)}"
    end
  end

  def prepare_datamap
    return unless fields.empty?

    set_metadata!
    datafile.with_file do |f|
      contents = CSV.read(f, headers: true)
      contents.headers.each_with_index do |heading, i|
        fields.create heading:, position: i,
                     unique_value_count: contents[heading].uniq.length,
                     empty_value_count: contents[heading].count(''),
                     sample_data: contents[heading].uniq[0..9]
      end
    end
  end

  def set_metadata!
    files.each(&:set_metadata!)
  end

  def analyze!
    return if analyzed?

    datafile.with_file do |f|
      contents = CSV.read(f, headers: true)
      fields.mapped.each do |field|
        field.min_value = contents[field.heading].compact.min
        field.max_value = contents[field.heading].compact.max

        if Field::VALUE_TYPES.include? field.common_type
          contents[field.heading].uniq.each do |value|
            field.unique_values.build value: value,
                                      frequency: contents[field.heading].count(value)
          end
        end

        field.save!
      end
    end

    update_attribute :analyzed, true
    reload.update_completion
  end

  def update_completion
    results = DataSets::Completion.new(self).calculate
    return true unless results

    update(results)
  end
end
# rubocop:enable all
