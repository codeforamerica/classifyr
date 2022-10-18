# frozen_string_literal: true

FactoryBot.define do
  factory(:classification) do
    association :common_incident_type
    association :user
    association :unique_value
    common_type { Faker::Lorem.word }
    value { Faker::Lorem.word }
  end
end
