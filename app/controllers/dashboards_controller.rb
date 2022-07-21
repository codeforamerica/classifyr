class DashboardsController < ApplicationController
  def index
    @call_type_maps = Classification.all.order(:value).includes(:common_incident_type)
  end

  def show; end
end
