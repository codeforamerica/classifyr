require "rails_helper"

RSpec.describe Field, type: :model do
  let(:field) { build(:field) }

  include_examples "valid factory", :field
  include_examples "papertrail versioning", :field, "position"
  include_examples "associations", :field, [:data_set, :unique_values]

  describe "constants" do
    it "has the TYPES constant defined" do
      expect(Field::TYPES).to eq(
        [
          "", "Emergency Category", "Call Category", Classification::CALL_TYPE,
          "-----------------", "Call Identifier", "Call Time", "Call Disposition", "Priority", "Dispatched Unit Type",
          "-----------------", "Geolocation Latitude", "Geolocation Longitude",
          "-----------------", "Flag Alcohol Related", "Flag Domestic Violence", "Flag Drug Related",
          "Flag Mental Health"
        ],
      )
    end

    it "has the VALUE_TYPES constant defined" do
      expect(Field::VALUE_TYPES).to eq(["Emergency Category", "Call Category", Classification::CALL_TYPE,
                                        "Call Disposition", "Priority"])
    end
  end

  describe "class methods" do
    describe ".mapped" do
      it "returns mapped fields" do
        mapped_field = create(:field, common_type: Field::VALUE_TYPES[1])
        create(:field, common_type: nil)

        expect(described_class.mapped).to eq [mapped_field]
      end
    end
  end

  describe "instance methods" do
    describe "#values?" do
      context "without a common_type" do
        it "returns true" do
          field = create(:field, common_type: Field::VALUE_TYPES[1])
          expect(field.values?).to be true
        end
      end

      context "with a common_type" do
        it "returns false" do
          field = create(:field, common_type: nil)
          expect(field.values?).to be false
        end
      end
    end
  end
end
