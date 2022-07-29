class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!

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
    controller_name == "registrations" && action_name == "edit"
  end
end
