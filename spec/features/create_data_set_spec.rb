require "rails_helper"

RSpec.describe "Create a data set", type: :feature do
  it "valid inputs" do
    visit root_path
    find("#sidenav").click_on "Datasets"
    click_on "Upload Dataset"

    fill_in "Title", with: "New Data Set"
    attach_file("data_set_files", File.absolute_path("spec/support/files/police-incidents-2022.csv"))

    click_on "Upload Dataset"

    expect(page).to have_content("Map Data Fields")
  end
end
