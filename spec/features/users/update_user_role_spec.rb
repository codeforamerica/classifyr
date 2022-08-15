require "rails_helper"

RSpec.describe "Update a user's role", type: :feature do
  it "updates the user's role successfully" do
    role = create(:role, name: :data_admin)
    user = create(:user, role:)
    volunteer_role = create(:role, name: :volunteer)
    volunteer = create(:user, role: volunteer_role)

    sign_in user

    visit root_path

    find("#sidenav").click_on "Users"
    expect(page).to have_content("List of users in the system.")

    find(:xpath, "//a[@href='/users/#{volunteer.id}/edit']", match: :first).click
    expect(page).to have_content(volunteer.email)
    expect(page).to have_content("Make updates to an existing user.")

    find("#user_role_id").find(:xpath, "option[1]").select_option

    expect do
      click_on "Update User"
    end.to change { volunteer.reload.role.id }.from(volunteer_role.id).to(role.id)
  end
end
