FactoryBot.define do
  factory(:data_set) do
    title { Faker::Lorem.word }
    files { [Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv")] }
  end
end
