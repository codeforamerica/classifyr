require "rails_helper"

RSpec.describe "Sign up", type: :feature do
  context "with valid inputs" do
    it "creates a new user account" do
      visit root_path

      # Not logged in, automatic redirect to log in path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("You need to sign in or sign up before continuing")

      click_on "Sign up"

      fill_in "Email", with: "test@example.com"
      fill_in "Password", with: "password"
      fill_in "Password confirmation", with: "password"

      click_on "Sign up"
      expect(page).to have_current_path(new_user_session_path)

      expect(ActionMailer::Base.deliveries.length).to eq(1)

      # Test email confirmation link
      email = ActionMailer::Base.deliveries.last
      html = Nokogiri::HTML(email.body.to_s)
      target_link = html.at("a:contains('Confirm my account')")
      visit target_link["href"]

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("Your email address has been successfully confirmed.")
    end
  end

  context "with blank inputs" do
    it "displays error messages" do
      visit root_path

      # Not logged in, automatic redirect to log in path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("You need to sign in or sign up before continuing")

      # Go to sign up page
      click_on "Sign up"

      # Submit the form
      click_on "Sign up"

      expect(page).to have_content("Email can't be blank.")
      expect(page).to have_content("Password can't be blank.")
    end
  end
end
