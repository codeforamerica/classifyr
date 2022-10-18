# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resend confirmation instructions', type: :feature do
  let(:user) { create(:user, confirmed_at: nil) }

  it 'resends confirmation instructions' do
    visit root_path

    click_on "Didn't receive confirmation instructions?"

    fill_in 'Email', with: user.email

    click_on 'Resend confirmation instructions'

    expect(page).to have_content(
      'You will receive an email with instructions for how to confirm your email address in a few minutes.'
    )

    # Test email reconfirmation link
    email = ActionMailer::Base.deliveries.last
    html = Nokogiri::HTML(email.body.to_s)
    target_link = html.at("a:contains('Confirm my account')")
    visit target_link['href']

    # Email confirmation link takes the user to the Log in page
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content('Your email address has been successfully confirmed.')
  end
end
