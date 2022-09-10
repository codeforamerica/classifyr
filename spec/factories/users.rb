FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::FunnyName.name }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { 5.minutes.ago }
    role { association(:role) }
  end
end
