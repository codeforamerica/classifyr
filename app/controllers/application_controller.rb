class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit

  layout :layout_by_resource

  private

  # Use logged-in layout when editing current_user details
  def layout_by_resource
    if devise_controller? && defined?(resource_name) && !my_profile?
      "devise"
    else
      "application"
    end
  end

  def my_profile?
    controller_name == "registrations" && %w[edit update].include?(action_name)
  end
end
