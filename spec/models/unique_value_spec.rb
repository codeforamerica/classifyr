require "rails_helper"

RSpec.describe UniqueValue, type: :model do
  include_examples "valid factory", :unique_value
  include_examples "papertrail versioning", :unique_value, "value"
  include_examples "associations", :unique_value, [:field, :classifications, :users]

  describe "scopes" do
    let(:role) { create(:role) }
    let(:jack) { create(:user, role:) }
    let(:john) { create(:user, role:) }

    let(:unique_value_1) { create(:unique_value, classifications_count: 2) } # + 1 (=3) from below
    let(:unique_value_2) { create(:unique_value, classifications_count: 0) } # + 2 = 2
    let(:unique_value_3) { create(:unique_value, classifications_count: 0) } # + 1 = 1
    let!(:unique_value_4) { create(:unique_value, classifications_count: 0) } # + 0 = 0

    before do
      create(:classification, unique_value: unique_value_1, user: jack)
      create(:classification, unique_value: unique_value_2, user: jack)
      create(:classification, unique_value: unique_value_2, user: john)
      create(:classification, unique_value: unique_value_3, user: john)
    end

    describe "ordered_by_completion" do
      it "returns unique_values sorted by completion" do
        expect(described_class.ordered_by_completion).to eq(
          [
            unique_value_4, unique_value_3,
            unique_value_2, unique_value_1
          ],
        )
      end
    end

    describe "not_completed" do
      it "returns unique_values that have less than 3 classifications_count" do
        expect(described_class.not_completed).to match_array(
          [
            unique_value_2, unique_value_3, unique_value_4
          ],
        )
      end
    end

    describe "classified_by" do
      it "returns all unique_values classified by a specific user" do
        expect(described_class.classified_by(jack)).to match_array(
          [
            unique_value_1, unique_value_2
          ],
        )
      end
    end

    describe "not_classified_by" do
      it "returns all unique_values not classified by a specific user" do
        expect(described_class.not_classified_by(jack)).to match_array(
          [
            unique_value_3, unique_value_4
          ],
        )
      end
    end
  end

  describe "instance methods" do
    describe "#examples" do
      it "returns X examples" do
        data_set = create(:data_set, files: [
                            Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
                          ])

        data_set.prepare_datamap
        data_set.fields.find_by(heading: "call_type").update(common_type: "Detailed Call Type")
        data_set.reload.analyze!

        expect(data_set.call_type_field.unique_values.first.examples).to eq(
          [[
            "22BU000002",
            "Welfare Check",
            "Public Service",
            "2021-12-31T20:08:55-05:00",
            "Main St",
            "911",
            "0",
            "1",
            "0",
            "1",
            "E",
            "SouthEnd",
            "44.475410548309",
            "-73.1971131641151",
            "1 am",
            "Saturday",
            "8",
            "East",
            "Priority 2",
            "January",
            "2022\r",
          ]],
        )
      end
    end
  end
end
