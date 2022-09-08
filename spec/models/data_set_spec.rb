require "rails_helper"
require "csv"

RSpec.describe DataSet, type: :model do
  let(:data_set) { build(:data_set) }

  include_examples "valid factory", :data_set
  include_examples "papertrail versioning", :data_set, "title"
  include_examples "associations", :data_set, [:files, :fields]

  describe "FriendlyID" do
    it "updates the slug when the title changes" do
      data_set = create(:data_set, title: "My New Data Set")
      expect(data_set.slug).to eq("my-new-data-set")

      data_set.update(title: "My Updated Data Set")
      expect(data_set.slug).to eq("my-updated-data-set")
    end
  end

  describe "scopes" do
    describe "ordered" do
      it "sorts data sets by creation date (desc)" do
        data_set_1 = create(:data_set)
        data_set_2 = create(:data_set)
        data_set_3 = create(:data_set)

        expect(described_class.ordered).to eq([
                                                data_set_3, data_set_2, data_set_1
                                              ])
      end
    end

    describe "to_classify" do
      it "filters data sets with call type fields and sorts them by
          completion percent and creation date" do
        data_set_1 = create(:data_set, id: 1)
        data_set_2 = create(:data_set, id: 2)
        data_set_3 = create(:data_set, id: 3)
        data_set_4 = create(:data_set, id: 4)
        _data_set_5 = create(:data_set, id: 5)

        field_1 = create(:field, data_set: data_set_1, common_type: Classification::CALL_TYPE)
        field_2 = create(:field, data_set: data_set_2, common_type: Classification::CALL_TYPE)
        field_3 = create(:field, data_set: data_set_3, common_type: Classification::CALL_TYPE)
        _field_4 = create(:field, data_set: data_set_4, common_type: Classification::CALL_TYPE)

        unique_value_1 = create(:unique_value, field: field_1)
        unique_value_2 = create(:unique_value, field: field_2)
        unique_value_3 = create(:unique_value, field: field_2)
        _unique_value_4 = create(:unique_value, field: field_3)

        create_list(:classification, 3, unique_value: unique_value_1) # completed
        # partially completed but interpreted as not completed
        create_list(:classification, 3, unique_value: unique_value_2)
        create_list(:classification, 1, unique_value: unique_value_3)

        # Oldest with lowest completion first
        expect(described_class.to_classify.map(&:id)).to \
          eq(
           [
             # data_set_5.id is not present because it doesn't have a Call Type field
             data_set_3.id, # Oldest one with no completion
             data_set_4.id, # More recent with no completion
             data_set_2.id, # Partial completion 1/2 unique values classified
             data_set_1.id, # Completed is last
           ],
         )
      end
    end
  end

  describe "instance methods" do
    describe "#call_type_field" do
      it "returns the data_set call_type field" do
        set = create(:data_set)
        create(:field, data_set: set, common_type: Field::VALUE_TYPES[1])
        create(:field, data_set: set, common_type: Field::VALUE_TYPES[5])
        field = create(:field, data_set: set, common_type: Classification::CALL_TYPE)

        expect(set.call_type_field).to eq(field)
      end
    end

    describe "#pick_value_to_classify_for" do
      it "returns a unique_value to classify" do
        user = create(:user)
        data_set = create(:data_set)
        field = create(:field, data_set:, common_type: Classification::CALL_TYPE)

        unique_value_1 = create(:unique_value, field:)
        unique_value_2 = create(:unique_value, field:)

        create_list(:classification, 3, unique_value: unique_value_1)

        expect(data_set.pick_value_to_classify_for(user)).to eq(unique_value_2)
      end
    end

    describe "completed?" do
      context "when completion_percent != 100" do
        it "returns false" do
          data_set = create(:data_set, completion_percent: 50)
          expect(data_set.completed?).to be(false)
        end
      end

      context "when completion_percent = 100" do
        it "returns true" do
          data_set = create(:data_set, completion_percent: 100)
          expect(data_set.completed?).to be(true)
        end
      end
    end

    describe "#field types" do
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

    describe "#time" do
      let(:datetime) { "2022-01-01 00:00:00" }
      let(:call_time_field) { create(:field, common_type: "Call Time", min_value: datetime) }

      describe "#start_time" do
        context "when there is one field with common_type = 'Call Time" do
          it "returns nil" do
            data_set = create(:data_set, fields: [call_time_field])
            expect(data_set.start_time).to eq(Chronic.parse(datetime))
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

    describe "#analyze!" do
      it "analyses a datafile" do
        data_set = create(:data_set, files: [
                            Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
                          ])

        data_set.prepare_datamap

        data_set.fields.find_by(heading: "incident_number").update(common_type: "Call Identifier")
        data_set.fields.find_by(heading: "call_type").update(common_type: "Detailed Call Type")
        data_set.fields.find_by(heading: "call_time").update(common_type: "Call Time")

        expect(data_set.reload.analyze!).to be(true)

        expect(data_set.fields.find_by(heading: "call_type").unique_values
                       .pluck(:value)).to(eq([
                                               "Welfare Check",
                                               "Fraud Under $250",
                                               "DUI",
                                               "Intoxication",
                                               "Mental Health Issue",
                                               "Trespass",
                                             ]))
      end
    end

    describe "#update_completion" do
      it "calls the DataSets::Completion service and update the correct attributes" do
        role = create(:role)
        jack = create(:user, role:)
        john = create(:user, role:)
        jane = create(:user, role:)

        data_set = create(:data_set)
        field = create(:field, data_set:, common_type: Classification::CALL_TYPE)

        unique_value_1 = create(:unique_value, field:) # 3/3, completed
        unique_value_2 = create(:unique_value, field:) # 2/3
        create(:unique_value, field:) # 0/3
        create(:unique_value, field:) # 0/3

        create(:classification, unique_value: unique_value_1, user: jack)
        create(:classification, unique_value: unique_value_1, user: john)
        create(:classification, unique_value: unique_value_1, user: jane)

        create(:classification, unique_value: unique_value_2, user: jack)
        create(:classification, unique_value: unique_value_2, user: john)

        # #update_completion is called after classification creation
        # data_set.update_completion

        expect(
          data_set.attributes.slice("completion_percent", "completed_unique_values", "total_unique_values"),
        ).to eq({
                  "completion_percent" => 25,
                  "completed_unique_values" => 1,
                  "total_unique_values" => 4,
                })
      end
    end
  end
end
