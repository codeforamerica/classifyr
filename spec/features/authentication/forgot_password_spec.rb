# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Forgot password' do
  let(:role) { create(:role, name: :volunteer) }
  let(:user) { create(:user, role:) }

  it 'sends an email to the user to reset their password' do
    visit root_path

    click_on 'Forgot your password?'

    fill_in 'Email', with: user.email

    click_on 'Send me reset password instructions'

    expect(page).to have_content(
      'You will receive an email with instructions on how to reset your password in a few minutes.'
    )

    # Expect confirmation email to be sent out
    expect(ActionMailer::Base.deliveries.length).to eq(1)

    # Test email confirmation link
    email = ActionMailer::Base.deliveries.last
    html = Nokogiri::HTML(email.body.to_s)
    target_link = html.at("a:contains('Change my password')")
    visit target_link['href']

    # Email confirmation link takes the user to the change password page
    expect(page).to have_content('Change your password')

    fill_in 'New password', with: 'password+1'
    fill_in 'Confirm new password', with: 'password+1'

    click_on 'Change my password'

    expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
  end
end
