class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :set_default_breadcrumbs
  after_action :verify_authorized

  layout :layout_by_resource

  rescue_from NotAuthorizedError, with: :not_authorized

  protected

  def authorize!(action, entity, record = nil)
    @_authorized = true

    raise NotAuthorizedError unless Authorizer.new(
      user: current_user,
      action:,
      entity:,
      record:,
    ).run
  end

  def set_default_breadcrumbs
    return if controller_name == "registrations"

    @default_breadcrumbs = [{
      name: controller_name.humanize,
      path: request.path,
    }]
  end

  def reset_default_breadcrumbs
    @default_breadcrumbs = nil
  end

  def add_breadcrumb(name, path = nil)
    @breadcrumbs ||= []
    @breadcrumbs << { name:, path: }
  end

  def disable_turbo
    @disable_turbo = true
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
