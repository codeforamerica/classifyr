FactoryBot.define do
  factory(:unique_value) do
    association :field
    value { Faker::Lorem.word }
    frequency { 1 }
  end
end
