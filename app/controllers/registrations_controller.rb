# frozen_string_literal: true

# Rails controller for user registration.
class RegistrationsController < Devise::RegistrationsController
  protected

  def after_inactive_sign_up_path_for(_resource)
    new_user_session_path
  end
end
