require "rails_helper"

RSpec.describe "Create a data set", type: :feature do
  let(:user) { create(:user) }

  context "with valid inputs" do
    it "creates the data set successfully" do
      sign_in user

      visit root_path
      find("#sidenav").click_on "Datasets"
      click_on "Upload Dataset"

      fill_in "Title", with: "New Data Set"
      attach_file("data_set_files", File.absolute_path("spec/support/files/police-incidents-2022.csv"))

      click_on "Upload Dataset"

      expect(page).to have_content("Map Data Fields")

      select "Call Identifier", from: "data_set_common_types[0]"
      select "Emergency Category", from: "data_set_common_types[1]"
      select "Detailed Call Type", from: "data_set_common_types[2]"

      click_on "Map Data Fields"

      expect(page).to have_content("Fields were successfully mapped.")

      # Check for data set state
      data_set = DataSet.last

      expect(data_set.analyzed?).to be(true)
      expect(data_set.fields.count).to eq(21)
      expect(data_set.fields.pluck(:heading)).to eq(
        %w[
          incident_number call_type call_type_group call_time Street call_origin
          mental_health drug_related dv_related alcohol_related Area AreaName
          Latitude Longitude Hour DayOfWeek WARD DISTRICT priority Month year
        ],
      )

      # We expect the 3 mapped fields to have a defined common_type
      expect(data_set.fields.where.not(common_type: nil).count).to eq(3)
    end
  end
end
