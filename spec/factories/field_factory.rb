FactoryBot.define do
  factory(:field) do
    association :data_set
    heading { Faker::Lorem.word }
    common_type { Field::VALUE_TYPES[rand(4)] }
  end
end
