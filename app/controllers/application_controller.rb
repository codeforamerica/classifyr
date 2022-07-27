class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  layout :layout_by_resource

  # Use logged-in layout when editing current_user details
  def layout_by_resource
    if devise_controller? && defined?(resource_name) && !my_profile?
      "devise"
    else
      "application"
    end
  end

  def my_profile?
    (
      [resource_name, action_name] == [:user, "edit"] ||
      [resource_name, action_name] == [:user, "update"]
    )
  end
end
