FactoryBot.define do
  factory(:classification) do
    association :common_incident_type
    association :user
    common_type { Faker::Lorem.word }
    value { Faker::Lorem.word }
  end
end
