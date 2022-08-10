class DashboardsController < ApplicationController
  before_action :set_breadcrumbs

  def index
    authorize! :index, :dashboard
    @call_type_maps = Classification.all.order(:value).includes(:common_incident_type)
  end

  def show
    authorize! :show, :dashboard
  end

  private

  def set_breadcrumbs
    add_breadcrumb("Dashboard", dashboards_path)
  end
end
