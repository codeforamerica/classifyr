require "rails_helper"

RSpec.describe CommonIncidentType, type: :model do
  let(:common_incident_type) { build(:common_incident_type) }

  include_examples "valid factory", :common_incident_type
  include_examples "papertrail versioning", :common_incident_type, "code"
  include_examples "associations", :common_incident_type, [:classifications]

  describe "constants" do
    it "has the TYPES constant defined" do
      expect(CommonIncidentType::EXPORT_COLUMNS).to eq(%w[id standard version code description notes humanized_code
                                                          humanized_description])
    end
  end

  describe "class methods" do
    describe ".to_csv" do
      it "generates a CSV" do
        common_incident_types = create_list(:common_incident_type, 3)

        csv = described_class.to_csv
        expect(csv).to include(CommonIncidentType::EXPORT_COLUMNS.join(","))

        common_incident_types.each do |common_incident_type|
          expect(csv).to include(common_incident_type.code)
        end
      end
    end
  end
end
