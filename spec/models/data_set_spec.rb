require "rails_helper"
require "csv"

RSpec.describe DataSet, type: :model do
  let(:data_set) { build(:data_set) }

  include_examples "valid factory", :data_set
  include_examples "papertrail versioning", :data_set, "title"
  include_examples "associations", :data_set, [:files, :fields]

  describe "instance methods" do
    describe "field types" do
      let(:emergency_field) { create(:field, :with_unique_values, common_type: "Emergency Category") }
      let(:call_field) { create(:field, :with_unique_values, common_type: "Call Category") }
      let(:detailed_call_field) { create(:field, :with_unique_values, common_type: Classification::CALL_TYPE) }
      let(:priority_field) { create(:field, :with_unique_values, common_type: "Priority") }

      let(:data_set) do
        create(:data_set, fields: [
                 emergency_field, call_field, detailed_call_field, priority_field
               ])
      end

      describe "#emergency_categories" do
        it "return the unique_values of the field matching the 'Emergency Category' type" do
          expect(data_set.emergency_categories).to eq(emergency_field.unique_values.order(:value))
        end
      end

      describe "#call_categories" do
        it "return the unique_values of the field matching the 'Call Category' type" do
          expect(data_set.call_categories).to eq(call_field.unique_values.order(:value))
        end
      end

      describe "#detailed_call_types" do
        it "return the unique_values of the field matching the 'Classification::CALL_TYPE' type" do
          expect(data_set.detailed_call_types).to eq(detailed_call_field.unique_values.order(:frequency))
        end
      end

      describe "#priorities" do
        it "return the unique_values of the field matching the 'Priority' type" do
          expect(data_set.priorities).to eq(priority_field.unique_values.order(:value))
        end
      end
    end

    describe "time" do
      let(:datetime) { "2022-01-01 00:00:00" }
      let(:call_time_field) { create(:field, common_type: "Call Time", min_value: datetime) }

      describe "#start_time" do
        context "when there is one field with common_type = 'Call Time" do
          it "returns nil" do
            data_set = create(:data_set, fields: [call_time_field])
            expect(data_set.start_time).to eq(DateTime.parse(datetime))
          end
        end

        context "when there are no fields with common_type != 'Call Time" do
          it "returns the parsed time" do
            data_set = create(:data_set)
            expect(data_set.start_time).to be_nil
          end
        end
      end
    end

    describe "analyze!" do
      it "analyses a datafile" do
        CSV.foreach(Rails.root.join("db/import/apco_common_incident_types_2.103.2-2019.csv"),
                    headers: true) do |line|
          CommonIncidentType.create! code: line[0], description: line["description"], notes: line["notes"]
        end

        data_set = create(:data_set, files: [
                            Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
                          ])

        data_set.prepare_datamap

        data_set.fields.find_by(heading: "incident_number").update(common_type: "Call Identifier")
        data_set.fields.find_by(heading: "call_type").update(common_type: "Call Category")
        data_set.fields.find_by(heading: "call_time").update(common_type: "Call Time")

        expect(data_set.reload.analyze!).to be(true)

        expect(data_set.fields.find_by(heading: "call_type").unique_values.pluck(:value)).to eq(
          [
            "Welfare Check",
            "Trespass",
            "Mental Health Issue",
            "Intoxication",
            "DUI",
          ],
        )
      end
    end
  end
end
