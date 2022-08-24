class DataSet < ApplicationRecord
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
    # check there's an attached file
    datafile.headers.split(",").each_with_index do |heading, i|
      datafile.with_file do |f|
        shorter = "cut -f#{i + 1} | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'"
        shorter2 = "cut -f#{i + 1} | grep -v -e '[[:space:]]*$' | wc -l"

        unique_value_count =
          `sed -E 's/("([^"]*)")?,/\2\t/g' #{f.path} | #{shorter} | sort | uniq | wc -l`.to_i - 1
        blank_value_count = `sed -E 's/("([^"]*)")?,/\2\t/g' #{f.path} | #{shorter2}`
        sample_data = `sed -E 's/("([^"]*)")?,/\2\t/g' #{f.path} | tail -n +2 | cut -f#{i + 1} | sort | uniq | head`
        fields.create heading:, position: i, unique_value_count:,
                      empty_value_count: blank_value_count, sample_data:
      end
    end
  end

  def set_metadata!
    files.each(&:set_metadata!)
  end

  # rubocop:disable all
  def analyze!
    return if analyzed?

    datafile.with_file do |f|
      fields.mapped.each do |field|
        # if field.common_type == 'Call Time'
        #   # parse dates and find earliest / latest
        # end

        field.min_value = `sed -E 's/("([^"]*)")?,/\2\t/g' #{f.path} | tail -n +2 | cut -f#{field.position + 1} | sort | uniq | head -1`&.chomp
        field.max_value = `sed -E 's/("([^"]*)")?,/\2\t/g' #{f.path} | tail -n +2 | cut -f#{field.position + 1} | sort | uniq | tail -1`&.chomp

        if Field::VALUE_TYPES.include? field.common_type
          `sed -E 's/("([^"]*)")?,/\2\t/g' #{f.path} | tail -n +2 | cut -f#{field.position + 1} | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//' | sort -rn | uniq -c`.split("\n").each do |line|
            x = line.strip.split("\s", 2)
            field.unique_values.build value: x[1], frequency: x[0]
          end
        end

        field.save!
      end
    end

    update_attribute :analyzed, true
    reload.update_completion
  end
  # rubocop:enable all

  def update_completion
    results = DataSets::Completion.new(self).calculate
    return true unless results

    update(results)
  end
end
