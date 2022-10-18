# frozen_string_literal: true

module DataSets
  # Service to provide dataset completion statistics.
  class Completion
    def initialize(data_set)
      @data_set = data_set
      @completed_unique_values = 0
    end

    def calculate
      return unless call_type

      call_type.unique_values.each do |unique_value|
        @completed_unique_values += 1 if unique_value.classifications_count > UniqueValue::COMPLETION_COUNT - 1
      end

      format
    end

    private

    def call_type
      # only expecting one Classification::CALL_TYPE field
      @call_type ||= @data_set.call_type_field
    end

    def format
      {
        completion_percent: @completed_unique_values * 100 / call_type.unique_values.count,
        completed_unique_values: @completed_unique_values,
        total_unique_values: call_type.unique_values.count
      }
    end
  end
end
