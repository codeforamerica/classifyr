# frozen_string_literal: true

# Represents a dataset to be classified.
# TODO: Refactor to remove disabled cops.
class DataSet < ApplicationRecord # rubocop:disable Metrics/ClassLength
  extend FriendlyId
  friendly_id :title, use: %i[slugged history]

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
    fields.find_by(common_type: 'Emergency Category').unique_values.order(:value)
  end

  def call_categories
    fields.find_by(common_type: 'Call Category').unique_values.order(:value)
  end

  def detailed_call_types
    fields.find_by(common_type: Classification::CALL_TYPE).unique_values.order(:frequency)
  end

  def priorities
    fields.find_by(common_type: 'Priority').unique_values.order(:value)
  end

  def start_time
    return unless (call_time = fields.find_by(common_type: 'Call Time')&.min_value)

    Chronic.parse call_time.gsub(/[[:^ascii:]]/, '')
  end

  def end_time
    return unless (call_time = fields.find_by(common_type: 'Call Time')&.max_value)

    Chronic.parse call_time.gsub(/[[:^ascii:]]/, '')
  end

  def timeframe(full: false)
    return unless start_time && end_time

    if full
      "#{start_time.to_date.to_fs(:display_date)} thru #{end_time.to_date.to_fs(:display_date)}"
    else
      "#{start_time.to_date.to_fs(:short_date)} - #{end_time.to_date.to_fs(:short_date)}"
    end
  end

  def prepare_datamap # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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

  def map_fields(common_types)
    common_types.each do |position, common_type|
      fields.find_by(position:).map_to(common_type)
    end
  end

  def analyze! # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    datafile.with_file do |f|
      fields_to_map = fields.mapped.not_classified
      CSV.foreach(f, headers: true) do |row|
        fields_to_map.each do |field|
          if field.min_value.nil?
            field.min_value = row[field.heading]
          elsif row[field.heading] < field.min_value
            field.min_value = row[field.heading]
          end

          if field.max_value.nil?
            field.max_value = row[field.heading]
          elsif row[field.heading] > field.max_value
            field.max_value = row[field.heading]
          end

        end
      end

      fields_to_map.each(&:save!)
    end

    update_attribute :analyzed, true # rubocop:disable Rails/SkipsModelValidations
    reload.update_completion
  end

  def update_completion
    results = DataSets::Completion.new(self).calculate
    return true unless results

    update(results)
  end
end
