require "rails_helper"

RSpec.describe UniqueValue, type: :model do
  include_examples "valid factory", :unique_value
  include_examples "papertrail versioning", :unique_value, "value"
  include_examples "associations", :unique_value, [:field, :classifications, :users]

  describe "scopes" do
    let(:role) { create(:role) }
    let(:jack) { create(:user, role:) }
    let(:john) { create(:user, role:) }

    let(:data_set_1) { create(:data_set, completion_percent: 33) }
    let(:data_set_2) { create(:data_set, completion_percent: 15) }

    let(:field_1) { create(:field, data_set: data_set_1, common_type: Classification::CALL_TYPE) }
    let(:field_2) { create(:field, data_set: data_set_2, common_type: Classification::CALL_TYPE) }

    let(:unique_value_1) { create(:unique_value, field: field_1) }
    let(:unique_value_2) { create(:unique_value, field: field_1) }
    let(:unique_value_3) { create(:unique_value, field: field_1) }
    let!(:unique_value_4) { create(:unique_value, field: field_2) }

    before do
      create(:classification, unique_value: unique_value_1)
      create(:classification, unique_value: unique_value_1)
      create(:classification, unique_value: unique_value_1)
      create(:classification, unique_value: unique_value_2, user: jack)
      create(:classification, unique_value: unique_value_2, user: john)
      create(:classification, unique_value: unique_value_3, user: john)
    end

    describe "to_classify_with_data_set_priority" do
      it "returns values to classify based on data set completion" do
        expect(described_class.to_classify_with_data_set_priority(jack)).to match_array(
          [
            unique_value_4, # data_set_2 has 15% completion so its value should come up first
            unique_value_3, # not classified by jack yet, in data_set_1
            # unique_value_2, classified by jack already
            # unique_value_1, # classified 3 times
          ],
        )
      end
    end

    describe "to_classify" do
      it "returns all values to classify for the given user" do
        expect(described_class.to_classify(jack)).to match_array(
          [
            unique_value_3,
            unique_value_4,
          ],
        )
      end
    end

    describe "call_types" do
      it "returns unique_values with a type of Classification::CALL_TYPE" do
        # The 4 unique values created in the before block
        expect(described_class.call_types).to match_array(
          [
            unique_value_1,
            unique_value_2,
            unique_value_3,
            unique_value_4,
          ],
        )
      end
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
        expect(described_class.classified_by(jack)).to match_array([unique_value_2])
      end
    end

    describe "not_classified_by" do
      it "returns all unique_values not classified by a specific user" do
        expect(described_class.not_classified_by(jack)).to match_array(
          [
            unique_value_1, unique_value_3, unique_value_4
          ],
        )
      end
    end
  end

  describe "instance methods" do
    describe "#update_approval_status" do
      let(:ratings) { Classification.confidence_ratings }
      let(:incident_type_1) { create(:common_incident_type, code: "Trespass") }
      let(:incident_type_2) { create(:common_incident_type, code: "DUI") }
      let(:unique_value) { create(:unique_value) }
      let(:datetime) { Time.utc(2022, 0o1, 0o1, 14, 0, 0) }

      before { travel_to datetime }

      context "when classifications_count is inferior to COMPLETION_COUNT (3)" do
        it "returns nil" do
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::SOMEWHAT_CONFIDENT])
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::SOMEWHAT_CONFIDENT])

          expect(unique_value.update_approval_status).to be_nil
          expect(unique_value.approved_at).to be_nil
          expect(unique_value.review_required).to be(false)
          expect(unique_value.auto_reviewed_at).to be_nil
        end
      end

      context "when classifications have different incident types" do
        it "sets the value as requiring review" do
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::SOMEWHAT_CONFIDENT])
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::SOMEWHAT_CONFIDENT])
          create(:classification, unique_value:, common_incident_type: incident_type_2,
                                  confidence_rating: ratings[Classification::VERY_CONFIDENT])

          expect(unique_value.approved_at).to be_nil
          expect(unique_value.review_required).to be(true)
          expect(unique_value.auto_reviewed_at).to eq(datetime)
        end
      end

      context "when one of the classifications has no confidence rating (unknown)" do
        it "sets the value as requiring review" do
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: nil)
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::SOMEWHAT_CONFIDENT])
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::VERY_CONFIDENT])

          expect(unique_value.approved_at).to be_nil
          expect(unique_value.review_required).to be(true)
          expect(unique_value.auto_reviewed_at).to eq(datetime)
        end
      end

      context "when one of the classifications has a 'Low Confidence' rating" do
        it "sets the value as requiring review" do
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::LOW_CONFIDENCE])
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::SOMEWHAT_CONFIDENT])
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::VERY_CONFIDENT])

          expect(unique_value.approved_at).to be_nil
          expect(unique_value.review_required).to be(true)
          expect(unique_value.auto_reviewed_at).to eq(datetime)
        end
      end

      context "when classifications have the same incident type and good enough confidence ratings" do
        it "approves the value" do
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::SOMEWHAT_CONFIDENT])
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::SOMEWHAT_CONFIDENT])
          create(:classification, unique_value:, common_incident_type: incident_type_1,
                                  confidence_rating: ratings[Classification::VERY_CONFIDENT])

          expect(unique_value.approved_at).to eq(datetime)
          expect(unique_value.review_required).to be(false)
          expect(unique_value.auto_reviewed_at).to be_nil
        end
      end
    end

    describe "#examples" do
      it "returns X examples" do
        data_set = create(:data_set, files: [
                            Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
                          ])

        data_set.prepare_datamap
        data_set.fields.find_by(heading: "call_type").update(common_type: "Detailed Call Type")
        data_set.reload.analyze!

        expect(data_set.call_type_field.unique_values.first.examples.flatten.map { |v| v.delete("\u0002") }).to eq(
          [
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
          ],
        )
      end
    end
  end
end
