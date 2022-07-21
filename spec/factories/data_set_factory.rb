FactoryBot.define do
  factory(:data_set) do
    title { Faker::Lorem.word }
    files { [Rack::Test::UploadedFile.new("spec/support/files/test.pdf", "application/pdf")] }
  end
end
