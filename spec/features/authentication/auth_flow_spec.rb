require "rails_helper"

RSpec.describe "Auth flow", type: :feature do
  before { Role.insert_roles }

  context "with valid inputs" do
    it "creates a new functional user account" do
      visit root_path

      # Not logged in, automatic redirect to log in path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("You need to sign in or sign up before continuing")

      # Go to Sign up page
      click_on "Sign up"

      # Fill in Sign up form
      fill_in "Email", with: "test@example.com"
      fill_in "Password", with: "password"
      fill_in "Password confirmation", with: "password"

      click_on "Sign up"

      # Redirects to Log in page
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("A message with a confirmation link has been sent to your email address.")

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

      # Logging in with newly created account
      fill_in "Email", with: "test@example.com"
      fill_in "Password", with: "password"
      find(:css, "#user_remember_me").set(true)

      click_on "Log in"

      # Confirm that the user was logged in
      expect(page).to have_content("Signed in successfully.")

      # Ensure the user has remember_me set to true
      expect(User.find_by(email: "test@example.com").remember_created_at).not_to be_nil

      # Log out
      find(:css, "#dropdown-button").click
      click_on "Sign Out"

      # Redirects to Log in page
      expect(page).to have_current_path(new_user_session_path)

      # Logging out resets remember_me to false
      expect(User.find_by(email: "test@example.com").remember_created_at).to be_nil
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
