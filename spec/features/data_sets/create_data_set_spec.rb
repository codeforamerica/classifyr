require "rails_helper"

RSpec.describe "Create a data set", type: :feature do
  let(:role) { create(:role, name: :data_admin) }
  let(:user) { create(:user, role:) }

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

  context "when modifying mappings" do
    let(:data_set) do
      create(:data_set, files: [
               Rack::Test::UploadedFile.new("spec/support/files/police-incidents-2022.csv", "text/csv"),
             ])
    end

    let(:call_type) { data_set.fields.find_by(heading: "call_type") }
    let(:incident_number) { data_set.fields.find_by(heading: "incident_number") }
    let(:call_type_group) { data_set.fields.find_by(heading: "call_type_group") }

    before do
      data_set.prepare_datamap

      call_type.update(common_type: "Detailed Call Type")

      # Oops, we mapped call_type_group and incident_number to the wrong types!
      incident_number.update(common_type: "Emergency Category")
      call_type_group.update(common_type: "Priority")

      data_set.reload.analyze!
    end

    it "re-maps all fields except the classified ones" do
      create(:classification, unique_value: data_set.call_type_field.unique_values.first)

      original_call_type_group_ids = call_type_group.unique_values.map(&:id)

      expect(call_type_group.unique_values.map(&:value)).to eq(
        ["Public Service", "Motor Vehicle", "Quality of Life", "Other"],
      )

      sign_in user
      visit root_path
      find("#sidenav").click_on "Datasets"

      find(:xpath, "//a[@href='/data_sets/#{data_set.slug}/map']", match: :first).click

      expect(page).to have_content("Map Data Fields")

      # Current mappings are pre-selected, classified ones are disabled
      expect(page).to have_select(
        "data_set[common_types[0]]",
        selected: "Emergency Category",
      )

      expect(page).to have_select(
        "data_set_common_types[1]",
        selected: "Detailed Call Type",
        disabled: true,
      )

      expect(page).to have_select(
        "data_set[common_types[2]]",
        selected: "Priority",
      )

      # Options for classified fields is disabled
      within("#data_set_common_types\\[2\\]") do
        expect(find("option[value='Detailed Call Type'][@disabled]")).to be_present
      end

      # Replace the wrong incident_number and call_type_group mappings
      select "", from: "data_set_common_types[0]"
      select "Call Category", from: "data_set_common_types[2]"

      click_on "Map Data Fields"
      expect(page).to have_content("Fields were successfully mapped.")

      data_set.reload
      call_type.reload
      incident_number.reload
      call_type_group.reload

      expect(incident_number.common_type).to be_nil
      expect(call_type_group.common_type).to eq("Call Category")

      # All unique values for the incident_number have been deleted
      # since its mapping was removed
      expect(incident_number.unique_values).to eq([])

      # The call type group unique values remain the same
      expect(call_type_group.unique_values.map(&:id)).to eq(original_call_type_group_ids)

      # The classified field was not modified
      expect(call_type.common_type).to eq("Detailed Call Type")
    end
  end
end
