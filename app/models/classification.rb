class Classification < ApplicationRecord
  has_paper_trail

  CALL_TYPE = "Detailed Call Type".freeze

  belongs_to :common_incident_type, optional: true
  belongs_to :user, optional: true
end
