require "rails_helper"

RSpec.describe Classification, type: :model do
  include_examples "valid factory", :classification
  include_examples "papertrail versioning", :classification, "value"
  include_examples "associations", :classification, [:common_incident_type, :user]

  describe "constants" do
    it "has the TYPES constant defined" do
      expect(Classification::CALL_TYPE).to eq("Detailed Call Type")
    end
  end
end
