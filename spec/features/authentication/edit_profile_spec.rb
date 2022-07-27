require "rails_helper"

RSpec.describe "Edit profile", type: :feature do
  let(:user) { create(:user) }

  it "updates the user email and sends a confirmation email" do
    sign_in user
    visit root_path

    find(:css, "#dropdown-button").click
    click_on "My Profile"

    fill_in "Email", with: "test+1@example.com"
    fill_in "Current password", with: "password"

    click_on "Update"

    expect(page).to have_content("You updated your account successfully")

    # Expect confirmation email to be sent out
    expect(ActionMailer::Base.deliveries.length).to eq(1)

    # Test email confirmation link
    email = ActionMailer::Base.deliveries.last
    html = Nokogiri::HTML(email.body.to_s)
    target_link = html.at("a:contains('Confirm my account')")
    visit target_link["href"]

    # Email confirmation link takes the user to the Log in page
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("Your email address has been successfully confirmed.")
  end

  it "updates the user password" do
    sign_in user
    visit root_path

    find(:css, "#dropdown-button").click
    click_on "My Profile"

    fill_in "Password", with: "password+1"
    fill_in "Password confirmation", with: "password+1"
    fill_in "Current password", with: "password"

    click_on "Update"

    expect(page).to have_content("Your account has been updated successfully.")
  end
end
