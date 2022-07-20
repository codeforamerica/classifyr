class Classification < ApplicationRecord
  CALL_TYPE = "Detailed Call Type".freeze

  belongs_to  :common_incident_type, optional: true

  def self.pick(type = Classification::CALL_TYPE)
    Field.where(common_type: type).order(Arel.sql("RANDOM()")).first.unique_values.order(Arel.sql("RANDOM()")).first
  end
end
