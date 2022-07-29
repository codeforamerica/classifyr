require "rails_helper"

RSpec.describe UniqueValue, type: :model do
  let(:unique_value) { build(:unique_value) }

  include_examples "valid factory", :unique_value
  include_examples "papertrail versioning", :unique_value, "value"

  describe "associations" do
    it "belongs_to a field" do
      expect(unique_value).to respond_to(:field)
    end
  end
end
