require "rails_helper"

RSpec.describe Classification, type: :model do
  include_examples "valid factory", :classification
  include_examples "papertrail versioning", :classification, "value"
  include_examples "associations", :classification, [
    :common_incident_type,
    :user,
    :unique_value,
  ]

  describe "constants" do
    it "has the TYPES constant defined" do
      expect(Classification::CALL_TYPE).to eq("Detailed Call Type")
    end
  end

  describe "enum" do
    context "when confidence_rating is an integer" do
      it "saves the confidence_rating" do
        classification = create(:classification)
        classification.confidence_rating = 1
        classification.save

        expect(classification.confidence_rating).to eq("Somewhat Confident")
      end
    end
  end

  describe "callbacks" do
    describe "#update_data_set_completion" do
      context "with associated unique_value" do
        it "calls update_completion on the related data_set" do
          expect_any_instance_of(DataSet).to receive(:update_completion)
          classification = build(:classification)
          classification.save
        end
      end

      context "without associated unique_value" do
        it "does nothing" do
          expect_any_instance_of(DataSet).not_to receive(:update_completion)
          classification = build(:classification, unique_value: nil)
          classification.save
        end
      end
    end
  end
end
