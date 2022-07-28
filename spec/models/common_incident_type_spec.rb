require "rails_helper"

RSpec.describe CommonIncidentType, type: :model do
  let(:common_incident_type) { build(:common_incident_type) }

  describe "factory" do
    it "has a valid factory" do
      expect(common_incident_type).to be_valid
    end
  end

  describe "versioning" do
    it "has versioning enabled on create" do
      common_incident_type = create(:common_incident_type)
      common_incident_type.update(code: 1)
      expect(common_incident_type.versions.count).to eq(2)
      expect(common_incident_type.versions.last.object_changes).to include("code")
    end
  end

  describe "associations" do
    it "has_many classifications" do
      expect(common_incident_type).to respond_to(:classifications)
    end
  end

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
