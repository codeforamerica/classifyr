require "rails_helper"
require "csv"

RSpec.describe "Classify call types", type: :feature, js: true do
  let(:role) { create(:role, name: :data_classifier) }
  let(:jack) { create(:user, role:) }
  let(:john) { create(:user, role:) }

  let!(:dui) {
    create(:common_incident_type, code: "DUI", description: "DUI",
                                  notes: "Driving while intoxicated, under the influence")
  }
  let!(:intox) {
    create(:common_incident_type, code: "INTOX", description: "INTOXICATED",
                                  notes: "Intoxicated person, drunk & disorderly")
  }

  let(:data_set_1) { create(:data_set) }
  let(:data_set_2) { create(:data_set) }

  let(:field_1) { create(:field, data_set: data_set_1, common_type: Classification::CALL_TYPE) }
  let(:field_2) { create(:field, data_set: data_set_2, common_type: Classification::CALL_TYPE) }

  let(:unique_value_1_1) { create(:unique_value, field: field_1, value: "Intoxication") }
  let(:unique_value_1_2) { create(:unique_value, field: field_1, value: "DUI") }
  let(:unique_value_1_3) { create(:unique_value, field: field_1, value: "Welfare Check") }

  let(:unique_value_2_1) { create(:unique_value, field: field_2, value: "Something") }

  before do
    create_list(:classification, 1, unique_value: unique_value_1_1)
    create_list(:classification, 2, unique_value: unique_value_1_2)
    create_list(:classification, 2, unique_value: unique_value_1_3)
  end

  def go_to_classify(user, data_set, percent = 0, completion = "0/3")
    sign_in user
    visit root_path
    find("#sidenav").click_on "Classification"
    check_data_set_card(data_set, percent, completion)

    find(:xpath, "//a[@href='/classifications/call_types/data_sets/#{data_set.id}/classify']", match: :first).click
  end

  def check_data_set_card(data_set, percent, completion)
    data_set_card = find("[data-data-set-id='#{data_set.id}']")

    expect(data_set_card).to have_content(data_set.title)
    expect(data_set_card).to have_content("#{percent}%")
    expect(data_set_card).to have_content(completion)
  end

  def check_classify_page(unique_value)
    expect(page).to have_content("Classify Call Type")
    expect(page).to have_content(unique_value.value)
    expect(page).to have_content("Search above to populate results")
  end

  def check_incident_type_card(incident_type)
    expect(page).to have_content(incident_type.code)
    expect(page).to have_content(incident_type.description)
    expect(page).to have_content(incident_type.notes)
  end

  def check_data_completion(data_set, percent, completed, total)
    data_set.reload

    expect(data_set.completion_percent).to eq(percent)
    expect(data_set.completed_unique_values).to eq(completed)
    expect(data_set.total_unique_values).to eq(total)
  end

  context "when selecting 'Unable to map call type'" do
    it "stores the classification as unknown" do
      go_to_classify(jack, data_set_1)
      check_classify_page(unique_value_1_1)

      fill_in "q", with: "something else"

      expect(page).to have_content("Unable to map call type")
      click_on "Select"
      expect(page).to have_content("Success! Your classification has been submitted.")

      unique_value_1_1.reload
      expect(unique_value_1_1.classifications_count).to eq(2)
      expect(unique_value_1_1.classifications.last.unknown).to be(true)
    end
  end

  context "when cancelling and trying again" do
    it "allows the user to search again" do
      go_to_classify(jack, data_set_1)
      check_classify_page(unique_value_1_1)

      fill_in "q", with: "into"

      expect(page).to have_content("Unable to map call type")
      check_incident_type_card(dui)
      check_incident_type_card(intox)

      find("[data-incident-id='#{intox.id}']").click_on("Select")
      expect(find("[data-incident-id='#{intox.id}']")).to have_content("Selected")

      expect(page).to have_css("#q[disabled]")

      click_on "Back"
      expect(find("[data-incident-id='#{intox.id}']")).not_to have_content("Selected")
      expect(page).not_to have_css("#q[disabled]")
    end
  end

  context "when a user has classified all call types for a data set" do
    context "when there are no other data sets" do
      it "redirects to the data sets page and show a notice" do
        # Ensure all unique values have all been classified by jack
        create(:classification, unique_value: unique_value_1_1, user: jack)
        create(:classification, unique_value: unique_value_1_2, user: jack)

        go_to_classify(jack, data_set_1, 33, "1/3")
        check_classify_page(unique_value_1_3)
        fill_in "q", with: "into"
        find("[data-incident-id='#{intox.id}']").click_on("Select")
        select "Very Confident", from: "classification[confidence_rating]"

        expect(unique_value_1_3.reload.classifications_count).to eq(2)
        click_on "Submit"

        click_on "Classify Another Call Type"
        expect(unique_value_1_3.reload.classifications_count).to eq(3)

        expect(page).to have_current_path("/classifications/call_types")
        expect(page).to have_content("All current data sets have been fully classified, thank you!")
      end
    end

    context "when there are more data sets to classify" do
      it "continues to the following data set" do
        # Ensure all unique values have all been classified by jack
        create(:classification, unique_value: unique_value_1_1, user: jack)
        create(:classification, unique_value: unique_value_1_2, user: jack)

        create_list(:classification, 1, unique_value: unique_value_2_1)

        go_to_classify(jack, data_set_1, 33, "1/3")
        check_classify_page(unique_value_1_3)
        fill_in "q", with: "into"
        find("[data-incident-id='#{intox.id}']").click_on("Select")
        select "Very Confident", from: "classification[confidence_rating]"

        expect(unique_value_1_3.reload.classifications_count).to eq(2)
        click_on "Submit"

        click_on "Classify Another Call Type"
        expect(unique_value_1_3.reload.classifications_count).to eq(3)

        expect(page).to have_current_path("/classifications/call_types/data_sets/#{data_set_2.id}/classify")
        expect(page).to have_content(data_set_2.title)
        expect(page).to have_content(unique_value_2_1.value)
      end
    end
  end

  context "when selecting a common incident" do
    it "creates the classification successfully" do
      # ----------------------------------- #
      # Do a first classification with Jack #
      # ----------------------------------- #
      go_to_classify(jack, data_set_1)
      check_classify_page(unique_value_1_1)

      fill_in "q", with: "into"

      expect(page).to have_content("Unable to map call type")
      check_incident_type_card(dui)
      check_incident_type_card(intox)

      find("[data-incident-id='#{intox.id}']").click_on("Select")
      expect(find("[data-incident-id='#{intox.id}']")).to have_content("Selected")

      select "Low Confidence", from: "classification[confidence_rating]"
      fill_in "classification[confidence_reasoning]", with: "I'm not sure."

      expect(unique_value_1_1.reload.classifications_count).to eq(1)
      click_on "Submit"

      expect(page).to have_content("Success! Your classification has been submitted.")
      expect(unique_value_1_1.reload.classifications_count).to eq(2)

      # completion percent, completed unique values, total unique values
      check_data_completion(data_set_1, 0, 0, 3)

      click_on "Classify Another Call Type"
      check_classify_page(unique_value_1_2)

      # ----------------------------------- #
      # Now do a classification with John #
      # ----------------------------------- #
      go_to_classify(john, data_set_1)

      # For some reason, the first fill_in doesn't trigger the search
      fill_in "q", with: "into"
      fill_in "q", with: "into"

      expect(page).to have_content("Unable to map call type", wait: 50)
      check_incident_type_card(intox)

      find("[data-incident-id='#{intox.id}']").click_on("Select")
      select "Very Confident", from: "classification[confidence_rating]"
      expect(page).not_to have_content("Describe your reasoning (optional)")

      expect(unique_value_1_1.reload.classifications_count).to eq(2)
      click_on "Submit"

      expect(page).to have_content("Success! Your classification has been submitted.")
      expect(unique_value_1_1.reload.classifications_count).to eq(3)

      # -------------------------------------------- #
      # With 3 classifications for unique_value_1_1, #
      # the completion of the data_set_1 changes       #
      # -------------------------------------------- #
      check_data_completion(data_set_1, 33, 1, 3)

      find("#sidenav").click_on "Classification"
      check_data_set_card(data_set_1, 33, "1/3")
    end
  end
end
