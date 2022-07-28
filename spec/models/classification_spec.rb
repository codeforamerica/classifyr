require "rails_helper"

RSpec.describe Classification, type: :model do
  let(:classification) { build(:classification) }

  include_examples "valid factory", :classification
  include_examples "papertrail versioning", :classification, "value"

  describe "associations" do
    it "belongs_to a common_incident_type" do
      expect(classification).to respond_to(:common_incident_type)
    end

    it "belongs_to a user" do
      expect(classification).to respond_to(:user)
    end
  end

  describe "constants" do
    it "has the TYPES constant defined" do
      expect(Classification::CALL_TYPE).to eq("Detailed Call Type")
    end
  end

  describe "class methods" do
    describe ".pick" do
      it "returns a random unique value with the given type on its associated field" do
        type = Field::VALUE_TYPES[0]
        field = create(:field, common_type: type)
        unique_value = create(:unique_value, field:)

        expect(described_class.pick(type)).to eq unique_value
      end
    end
  end
end
