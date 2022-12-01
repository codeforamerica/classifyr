# frozen_string_literal: true

# Represents a dataset to be classified.
# TODO: Refactor to remove disabled cops.
class DataSet < ApplicationRecord # rubocop:disable Metrics/ClassLength
  extend FriendlyId
  include ShellCommand

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
      command = "xsv index #{f.path} && xsv stats --cardinality #{f.path} | yq -p csv -o json"
      Rails.logger.debug(command)
      r = exec_command(command)
      # result = JSON.parse(exec_command(command), symbolize_names: true)
      result = JSON.parse(r, symbolize_names: true)

      result.each_with_index.map do |column, i|
        samples = exec_command("xsv select #{column[:field]} #{f.path} " \
                               '| xsv search "[^\s]" | xsv sort | uniq | ' \
                               'head -n 11 | tail -n +2')
        empties = exec_command("xsv search -vs #{column[:field]} '[^\\s]' #{f.path} " \
                               "| xsv frequency -s #{column[:field]} -l1 " \
                               '| xsv select count | tail -n 1')
        fields.create heading: column[:field], position: i,
                      unique_value_count: column[:cardinality],
                      empty_value_count: empties,
                      min_value: column[:min],
                      max_value: column[:max],
                      sample_data: samples.split("\n")
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
      # Create an index of the CSV for faster processing.
      exec_command('xsv', 'index', f.path)

      fields.mapped.not_classified.each do |field|
        # If the field has unique values, it has already been analyzed
        next unless Field::VALUE_TYPES.include?(field.common_type) && field.unique_values.none?

        values = exec_command("xsv search -s #{field.heading} '[^\\s]' #{f.path} " \
                             "| xsv frequency -s #{field.heading} -l0" \
                             '| xsv select value,count | yq -p csv -o json')
        JSON.parse(values, symbolize_names: true).each do |value|
          field.unique_values.build value: value[:value],
                                    frequency: value[:count]
          field.save!
        end

      end
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
