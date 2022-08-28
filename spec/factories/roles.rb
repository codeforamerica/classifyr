FactoryBot.define do
  factory :role do
    name { Faker::Internet.uuid }
  end
end
