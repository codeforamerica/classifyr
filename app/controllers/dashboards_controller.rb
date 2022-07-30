class DashboardsController < ApplicationController
  def index
    authorize! :index, :dashboard
    @call_type_maps = Classification.all.order(:value).includes(:common_incident_type)
  end

  def show
    authorize! :show, :dashboard
  end
end
