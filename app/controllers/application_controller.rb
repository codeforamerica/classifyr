class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized

  layout :layout_by_resource

  rescue_from NotAuthorizedError, with: :not_authorized

  protected

  def authorize!(action, entity)
    @_authorized = true
    raise NotAuthorizedError unless current_user&.role&.authorized?(action, entity)
  end

  private

  def not_authorized
    redirect_to dashboards_path, alert: "You are not authorized to access this page."
  end

  def verify_authorized
    raise MissingAuthorizationError unless @_authorized || devise_controller?
  end

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
