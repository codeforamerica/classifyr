# frozen_string_literal: true

FactoryBot.define do
  factory(:common_incident_type) do
    standard { 'APCO' }
    version { '2.103.2-2019' }
    code { Faker::Code.npi }
    description { Faker::Lorem.paragraph }
    notes { Faker::Lorem.paragraph }
  end
end
