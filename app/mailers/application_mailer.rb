# frozen_string_literal: true

# Base application mailer configurtion.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
