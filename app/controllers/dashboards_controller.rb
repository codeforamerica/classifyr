class DashboardsController < ApplicationController
  before_action :set_breadcrumbs

  def index
    authorize! :index, :dashboard
    redirect_to call_types_classifications_path
  end

  def show
    authorize! :show, :dashboard
  end

  private

  def set_breadcrumbs
    add_breadcrumb("Dashboard", dashboards_path)
  end
end
